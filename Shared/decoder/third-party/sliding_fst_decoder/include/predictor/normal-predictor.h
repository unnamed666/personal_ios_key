/*
 * normal-predictor.h
 *
 *  Created on: Jun 23, 2017
 *      Author: yangchen
 */

#ifndef NORMAL_PREDICTOR_H_
#define NORMAL_PREDICTOR_H_

#include "fst/fstlib.h"

using namespace fst;

/**
 *
 */
class NormalPredictor {
	using StateId = fst::StdArc::StateId;
	using Label = fst::StdArc::Label;
	typedef float BaseFloat;

public:
	NormalPredictor(const fst::Fst<fst::StdArc> &fst) : fst_(fst), matcher(fst, MATCH_INPUT) {
		// init params
		// TODO: make a config struct
		topk_k = 3;
		eps_label = 0;
		unk_label = -1;
		caching_threshold = 1000;

		// init
		current_state = fst.Start();

		// find out unigram state
		// caution: make assumption about unigram state: one eps arc after init state.
		bool found = false;
		for (ArcIterator<StdFst> aiter(fst, fst.Start()); !aiter.Done(); aiter.Next()) {
			const StdArc &arc = aiter.Value();
			if (arc.ilabel == eps_label) {
				unigram_state = arc.nextstate;
				found = true;
				// cout << "found" << endl;
				break;
			}
		}
		if (!found)
			cout << "unigram state not found!";

		// pre cache the states with large outdegree
		// this is easy to implement but hard to exactly know the memory cost
		// and slow at initialization
		for (StateIterator<StdFst> siter(fst_); !siter.Done(); siter.Next()) {
			StateId state = siter.Value();
			if (fst.NumArcs(state) > caching_threshold) {
				vector<pair<Label, BaseFloat>> predictions;
				topk_arcs(state, topk_k, predictions);
				prediction_cache[state] = predictions;
			}
		}
	}

	~NormalPredictor() {}

	// follow all back-off arcs
	void get_predictions(vector<pair<Label, BaseFloat>> &predictions) {

		predictions_from_one_state(current_state, predictions);
		matcher.SetState(current_state);

		// follow backoff arcs
		// if we found enough predictions from current state, will not go back.
		while (matcher.Find(eps_label) && predictions.size() < topk_k) {
			matcher.Next();                       // this is a pitfall.
			const StdArc &arc = matcher.Value();  // caution: assume only one eps arc.

			vector<pair<Label, BaseFloat>> pred;
			predictions_from_one_state(arc.nextstate, pred);
			predictions.insert(predictions.end(), pred.begin(), pred.end());
			merge_predictions(predictions);

			matcher.SetState(arc.nextstate);
		}
		sort_predcitions_by_scores(predictions);

		int num_predictions = predictions.size();
		num_predictions = min(topk_k, num_predictions);
		predictions.resize(num_predictions);
	}

	StateId set_input(Label input) {
		matcher.SetState(current_state);
		if (matcher.Find(input)) {  // find input from current state
//			for (; !matcher.Done(); matcher.Next()) {
//				const StdArc &arc = matcher.Value();
//				cout << "ilabel " << arc.ilabel << " olabel " << arc.olabel << endl;
//				cout << "next state: " << arc.nextstate << endl;
//			}
			// matcher.Next();
			const StdArc &arc = matcher.Value();  // caution: make assumption here, there is at most one arc with specific label in one state.
			current_state = arc.nextstate;        // if context from current state found, we do not compare with back-off pathes.
		} else if (current_state != unigram_state) { // if already in unigram state but still can not find an arc, stay at unigram_state.
			matcher.SetState(current_state);
			while (matcher.Find(eps_label)) {
				matcher.Next();
				const StdArc &back_arc = matcher.Value();

				matcher.SetState(back_arc.nextstate);
				if (matcher.Find(input)) {
					//matcher.Next();
					const StdArc &arc = matcher.Value();
					current_state = arc.nextstate;
					break;
				}
				matcher.SetState(back_arc.nextstate);
			}
		}
		return current_state;
	}

	StateId set_input(vector<Label> input) {
		for (vector<Label>::iterator iter = input.begin(); iter != input.end(); iter++) {
			set_input(*iter);
		}
		return current_state;
	}

	StateId reset() {
		current_state = fst_.Start();
		return current_state;
	}

	StateId reset(StateId lm_state_back) {
		current_state = lm_state_back;
		return current_state;
	}

	void set_topk(int k) {
		topk_k = k;
	}

	void set_unk_label(Label l) {
		unk_label = l;
	}

	void set_eps_label(Label l) {
		eps_label = l;
	}

private:
	const fst::Fst<fst::StdArc> &fst_;
	Matcher<StdFst> matcher;
	StateId current_state;
	StateId unigram_state;
	Label eps_label;
	Label unk_label;
	int topk_k;
	int caching_threshold; // for pre caching.
	unordered_map<StateId, vector<pair<Label, BaseFloat>>> prediction_cache;

	void topk_arcs(StateId lm_state, int k, vector<pair<Label, BaseFloat>> &predictions) {
		// top k while iterating arcs, saving memories.
		struct value_comp {  // pop the largest value first
			bool operator()(const pair<Label, BaseFloat> &a, const pair<Label, BaseFloat> &b) {
				return a.second < b.second;
			}
		};
		priority_queue<pair<Label, BaseFloat>, vector<pair<Label, BaseFloat>>, value_comp> heap;
		int kk = 0;
		ArcIterator<StdFst> aiter(fst_, lm_state);
		for (; !aiter.Done(); aiter.Next()) {
			const StdArc &arc = aiter.Value();
			if (kk > k-1)
				break;
			if (arc.olabel == eps_label || arc.olabel == unk_label)
				continue;
			pair<Label, BaseFloat> e(arc.ilabel, arc.weight.Value());
			heap.push(e);
			kk++;
		}
		for (; !aiter.Done(); aiter.Next()) {
			const StdArc &arc = aiter.Value();
			if (arc.olabel == eps_label || arc.olabel == unk_label)
				continue;
			if (arc.weight.Value() < heap.top().second) {
				pair<Label, BaseFloat> e(arc.ilabel, arc.weight.Value());
				heap.pop();
				heap.push(e);
			}
		}
		int realk = heap.size();
		for (kk = 0; kk < realk; kk++) {
			predictions.push_back(heap.top());
			heap.pop();
		}
//		reverse(predictions.begin(), predictions.end()); // sorting outside
	}

	void predictions_from_one_state(StateId state, vector<pair<Label, BaseFloat>> &predictions) {
		if (prediction_cache.find(state) == prediction_cache.end())
			topk_arcs(state, topk_k, predictions);
		else
			predictions = prediction_cache[state];
	}

	void sort_predcitions_by_scores(vector<pair<Label, BaseFloat>> &predictions) {

		typedef pair<Label, BaseFloat> PAIR;
		struct CmpByValue {
		  bool operator()(const PAIR& lhs, const PAIR& rhs) {
			return lhs.second < rhs.second;
		  }
		};
		std::sort(predictions.begin(), predictions.end(), CmpByValue());
	}

	void merge_predictions(vector<pair<Label, BaseFloat>> &predictions) {
		unordered_map<Label, BaseFloat> uni;
		for (vector<pair<Label, BaseFloat>>::iterator iter = predictions.begin(); iter != predictions.end(); iter++) {
			Label lab = iter->first;
			BaseFloat val = iter->second;
			if (uni.find(lab) == uni.end())
				uni[lab] = val;
			else if (uni[lab] > val)
				uni[lab] = val;
		}
		// TODO: maybe you should use map for the structure of predictions
		predictions.clear();
		for (unordered_map<Label, BaseFloat>::iterator iter = uni.begin(); iter != uni.end(); iter++) {
			pair<Label, BaseFloat> e(iter->first, iter->second);
			predictions.push_back(e);
		}
	}
};

#endif /* NORMAL_PREDICTOR_H_ */


