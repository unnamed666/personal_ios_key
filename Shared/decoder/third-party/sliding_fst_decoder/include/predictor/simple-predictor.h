/*
 * simple-predictor.h
 *
 *  Created on: Jun 22, 2017
 *      Author: yangchen
 */

#ifndef SIMPLE_PREDICTOR_H_
#define SIMPLE_PREDICTOR_H_

#include "fst/fstlib.h"

using namespace fst;

/**
 *
 */
class SimplePredictor {
	using StateId = fst::StdArc::StateId;
	using Label = fst::StdArc::Label;
	typedef float BaseFloat;

public:
	SimplePredictor(const fst::Fst<fst::StdArc> &fst):fst_(fst), matcher(fst, MATCH_INPUT) {
		// init params
		topk_k = 3;
		eps_label = 0;
		unk_label = -1;
		caching_threshold = 100;

		// init
		current_state = fst.Start();

		// find out unigram state
		// caution: make assumption about unigram state: one eps arc after init state.
		bool found;
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

	~SimplePredictor() {}

	// not following back-off arcs, so no prediction when the context do not exist.
	void get_predictions(vector<pair<Label, BaseFloat>> &predictions) {
		if (prediction_cache.find(current_state) == prediction_cache.end())
			topk_arcs(current_state, topk_k, predictions);
		else
			predictions = prediction_cache[current_state];
	}

	// In SimplePredictor, we will not follow all the back-off arcs,
	// if the context is not found, go back to the unigram state and use one word context for prediction (bigram),
	// this is valid for bigram and trigram model, but maybe problematic for high order lm.
	StateId set_input(Label input) {
		matcher.SetState(current_state);
		if (matcher.Find(input)) {
			const StdArc &arc = matcher.Value();  // caution: make assumption here, there is at most one arc with specific label in one state.
			current_state = arc.nextstate;
		} else {
			current_state = unigram_state;  // if still not found, stay in the unigram state.
			matcher.SetState(current_state);
			if (matcher.Find(input)) {
				const StdArc &arc = matcher.Value();
				current_state = arc.nextstate;
			}
		}
		return current_state;
	}

	StateId set_input(vector<Label> input) {
		for (vector<Label>::iterator iter = input.begin(); iter != input.end; iter++) {
			set_input(*iter);
		}
		return current_state;
	}

	StateId reset() {
		current_state = fst_.Start();
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
		reverse(predictions.begin(), predictions.end());
	}
};
#endif /* SIMPLE_PREDICTOR_H_ */


