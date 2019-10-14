/*
 * ios_lattice_biglm_faster_decoder.cc
 *
 *  Created on: Jun 22, 2017
 *      Author: jn
 */

#include "ios_lattice_biglm_faster_decoder.h"
#include <fst/extensions/ngram/ngram-fst.h>
IOSLatticeBiglmFasterDecoder::IOSLatticeBiglmFasterDecoder(){
	lfst = NULL;

	decoder = NULL;

	isym = NULL;
	osym = NULL;
	
	gfst = NULL;
	
	predictor = NULL;
	
	cache_dfst = NULL;
	new_lm_dfst = NULL;
    
    unigram_state = 0;
}

void IOSLatticeBiglmFasterDecoder::Release(){
	if(lfst!=NULL){
		delete lfst;
		lfst = NULL;
	}
	if(decoder!=NULL){
		delete decoder;
		decoder = NULL;
	}
	if (isym!=NULL) {
		delete isym;
		isym = NULL;
	}
	if(osym!=NULL){
		delete osym;
		osym = NULL;
	}
	if(predictor!=NULL) {
		delete predictor;
		predictor = NULL;
	}
	if(gfst!=NULL) {
		delete gfst;
		gfst = NULL;
	}
	if (cache_dfst!=NULL) {
		delete cache_dfst;
		cache_dfst = NULL;
	}
	if (new_lm_dfst!=NULL) {
		delete new_lm_dfst;
		new_lm_dfst = NULL;
	}
}

bool IOSLatticeBiglmFasterDecoder::ReadLexiconFst(const string &filename){

//	lfst = fst::Fst<fst::StdArc>::Read(filename);
	
	std::ifstream strm(filename.c_str(),
					   std::ios_base::in | std::ios_base::binary);
	if (!strm) {
		LOG_FST(ERROR) << "Fst::Read: Can't open file: " << filename;
		return nullptr;
	}
	FstReadOptions opt(filename);
	opt.mode = FstReadOptions::ReadMode("map");
	lfst = fst::StdConstFst::Read(strm, opt);
	
	return true;
}

bool IOSLatticeBiglmFasterDecoder::ReadLmFst(const string &filename){

//	gfst = fst::Fst<fst::StdArc>::Read(filename);//"lm.mod"

	std::ifstream strm(filename.c_str(),
					   std::ios_base::in | std::ios_base::binary);
	if (!strm) {
		LOG_FST(ERROR) << "Fst::Read: Can't open file: " << filename;
		return nullptr;
	}
	FstReadOptions opt(filename);
	opt.mode = FstReadOptions::ReadMode("map");
	gfst = fst::StdConstFst::Read(strm, opt);

	lm_state = gfst->Start();

	return GenerateDecoder();
}
bool IOSLatticeBiglmFasterDecoder::ReadLmFst(const string &filename,
		BaseFloat _beam,int32 _max_active,int32 _min_active,BaseFloat _lattice_beam,
	    int32 _prune_interval,bool _determinize_lattice,BaseFloat _beam_delta,BaseFloat _hash_ratio,BaseFloat _prune_scale){

//	gfst = fst::Fst<fst::StdArc>::Read(filename);//"lm.mod"

	std::ifstream strm(filename.c_str(),
					   std::ios_base::in | std::ios_base::binary);
	if (!strm) {
		LOG_FST(ERROR) << "Fst::Read: Can't open file: " << filename;
		return nullptr;
	}
	FstReadOptions opt(filename);
	opt.mode = FstReadOptions::ReadMode("map");
	gfst = fst::StdConstFst::Read(strm, opt);

	lm_state = gfst->Start();

	return GenerateDecoder( _beam, _max_active, _min_active, _lattice_beam,
		     _prune_interval, _determinize_lattice, _beam_delta, _hash_ratio, _prune_scale);

}

bool IOSLatticeBiglmFasterDecoder::GenerateDecoder(){

	if(lfst!=NULL && gfst!=NULL){

		new_lm_dfst = new fst::BackoffDeterministicOnDemandFst<fst::StdArc>(*gfst);
		cache_dfst = new fst::CacheDeterministicOnDemandFst<fst::StdArc>(new_lm_dfst, 1000);
		const LatticeBiglmFasterDecoderConfig config;
		decoder = new LatticeBiglmFasterDecoder(*lfst, config, cache_dfst);

		predictor = new NormalPredictor(*gfst);  // should set the special labelid for predictor, should ReadIOSyms first.
		return true;
	}

	return false;

}

bool IOSLatticeBiglmFasterDecoder::GenerateDecoder(
		BaseFloat _beam,int32 _max_active,int32 _min_active,BaseFloat _lattice_beam,
	    int32 _prune_interval,bool _determinize_lattice,BaseFloat _beam_delta,BaseFloat _hash_ratio,BaseFloat _prune_scale){

	if(lfst!=NULL && gfst!=NULL){

		new_lm_dfst = new fst::BackoffDeterministicOnDemandFst<fst::StdArc>(*gfst);
		cache_dfst = new fst::CacheDeterministicOnDemandFst<fst::StdArc>(new_lm_dfst, 1000);
		LatticeBiglmFasterDecoderConfig config;

		config.InitParams(_beam, _max_active, _min_active, _lattice_beam,
			_prune_interval, _determinize_lattice, _beam_delta, _hash_ratio, _prune_scale);

		decoder = new LatticeBiglmFasterDecoder(*lfst, config, cache_dfst);

		predictor = new NormalPredictor(*gfst);  // should set the special labelid for predictor, should ReadIOSyms first.
		return true;
	}

	return false;

}

bool IOSLatticeBiglmFasterDecoder::ReadIOSyms(const string&isymfilename,const string &osymfilename){

	isym = fst::SymbolTable::ReadText(isymfilename);//"char.syms"

	osym = fst::SymbolTable::ReadText(osymfilename);//"word.syms"

	return true;
}

bool IOSLatticeBiglmFasterDecoder::FindUniGramState(){
	// caution: make assumption about unigram state: one eps arc after init state.
    return true;
//    bool found;
//
//    for (fst::ArcIterator<fst::Fst<fst::StdArc>> aiter(*gfst, lm_state); !aiter.Done(); aiter.Next()) {
//
//        const fst::StdArc &arc = aiter.Value();
//
//        if (arc.ilabel == osym->Find(EPSILON_STRING)) {
//
//            unigram_state = arc.nextstate;
//
//            found = true;
//
//            break;
//        }
//    }
//
//    if (!found)
//        cout << "unigram state not found!";
//
//    return found;
}

bool IOSLatticeBiglmFasterDecoder::Decode(IOSDecodable *decodable){
	// re-init decoding with current given lm_state.
	decoder->ResetDecoding(lm_state);

	// decode
	decoder->Decode(decodable->GetRawKaldiDecodable());
	return true;
}
//bool IOSLatticeBiglmFasterDecoder::DecodeTest(IOSDecodableTest *decodable){
//	// re-init decoding with current given lm_state.
//	decoder->ResetDecoding(lm_state);
//
//	// decode
//	decoder->Decode(decodable->GetRawKaldiDecodable());
//	return true;
//}
std::vector<string> IOSLatticeBiglmFasterDecoder::GetSuggestionWord(){
	CompactLattice lat;
    std::vector<string> result;
    if(!decoder->GetLattice(&lat, true)){
        //std::vector<string> result;
        return result;
    }
	CompactLattice nbest_lat;
    fst::ShortestPath(lat, &nbest_lat, 9);
    std::vector<CompactLattice> nbest_lats;
    fst::ConvertNbestToVector(nbest_lat,&nbest_lats);
	//std::vector<string> result;

    if (nbest_lats.empty()) {
    } else {
    	  const fst::SymbolTable *private_osym = nbest_lat.OutputSymbols();
      	  if(osym == NULL){
	      	 return result;
      	  }
		  for (int32 k = 0; k < static_cast<int32>(nbest_lats.size()); k++) {
			  CompactLattice single = nbest_lats[k];
			  string word;
			  for (fst::StateIterator<CompactLattice> siter(single); !siter.Done(); siter.Next()){
				  StateId state_id = siter.Value();
				  for (fst::ArcIterator<CompactLattice> aiter(single, state_id); !aiter.Done(); aiter.Next())
				  {
					  const CompactLatticeArc &arc = aiter.Value();
					  //arc.olabel;
					  //cout<<arc.olabel<<endl;
					  if(arc.olabel != EPSILON_OF_WORDSYMS){
						  //cout<<arc.olabel<<endl;
						  word += osym->Find(arc.olabel);
					  }

				  }
			  }
			  if	 (word.length() > 0) {
				  result.push_back(word);
			  } else {
				  cout << "Empty lattice." << endl;
			  }

		  }
    }
	return result;
}

void IOSLatticeBiglmFasterDecoder::ResetBeforePredict(vector<string> input){
	vector<fst::StdArc::Label> input_label;
	for (vector<string>::iterator iter = input.begin(); iter != input.end(); iter++) {
		string word = *iter;

		fst::StdArc::Label word_label = osym->Find(word);

		input_label.push_back(word_label);
	}

	predictor->reset();
	predictor->set_input(input_label);
}

void IOSLatticeBiglmFasterDecoder::ResetPredict(){
	predictor->reset();
}

std::vector<string> IOSLatticeBiglmFasterDecoder::GetPredictWord(string user_chose_word, int k){

	// find new lm_state
	fst::StdArc::Label input_label = osym->Find(user_chose_word);
	lm_state = predictor->set_input(input_label);

	// get predictions
	predictor->set_topk(k);
	vector<pair<fst::StdArc::Label, BaseFloat>> predictions;
	predictor->get_predictions(predictions);
	std::vector<string> result;
	for (int kk = 0; kk < predictions.size(); kk++) {
		string s = osym->Find(predictions[kk].first);
		result.push_back(s);
	}
	return result;


//	// find out new lm_state from outside the decoder.
//	// TODO: you should follow back-off arcs?
//	set<StateId> state_set;
//	bool found = false;
//	for (fst::ArcIterator<fst::StdFst> aiter(*gfst, lm_state); !aiter.Done(); aiter.Next()) {
//
//		const fst::StdArc &arc = aiter.Value();
//
//		if (arc.ilabel == osym->Find(user_chose_word)) {
//			//how to update weight of l-fst.?
//
//			lm_state = arc.nextstate;
//
//			found = true;
//			break;
//		}
//	}
//	if (!found) {
//
//		cout << "go back to unigram state" << endl;
//
//		lm_state = unigram_state;
//
//		//bool find_after_uni = false;
//		for (fst::ArcIterator<fst::StdFst> aiter(*gfst, lm_state); !aiter.Done(); aiter.Next()) {
//			const fst::StdArc &arc = aiter.Value();
//
//			if (arc.ilabel == osym->Find(user_chose_word)) {//always in this.
//
//				lm_state = arc.nextstate;
//				//find_after_uni = true;
//				//cout << "after uni state" << endl;
//
//				break;
//			}
//		}
//		//if(!find_after_uni){
//			//cout << "Error, unigram state don't find a arc with this user chosen word.." << endl;
//			//exit(0);
//		//}
//	}
//	//update lm_state finished!
//
//	// get prediction
//	fst::StdArc::Label eps_label = osym->Find(EPSILON_STRING);
//	fst::StdArc::Label unk_label = osym->Find(UNKNOW_STRING);
//
//	vector<pair<fst::StdArc::Label, BaseFloat>> predictions;
//	//int k = 3;
//
//	// top k while iterating arcs
//	struct value_comp {  // pop the largest value first
//		bool operator()(const pair<fst::StdArc::Label, BaseFloat> &a, const pair<fst::StdArc::Label, BaseFloat> &b) {
//			return a.second < b.second;
//		}
//	};
//
//	priority_queue<pair<fst::StdArc::Label, BaseFloat>,vector<pair<fst::StdArc::Label, BaseFloat>>, value_comp> heap;
//
//	fst::ArcIterator<fst::StdFst> aiter(*gfst, lm_state);
//
//	int kk = 0;
//
//	for (; !aiter.Done(); aiter.Next()) {
//
//		const fst::StdArc &arc = aiter.Value();
//
//		if (kk > k-1)
//			break;
//
//		if (arc.olabel == eps_label || arc.olabel == unk_label)
//			continue;
//
//		pair<fst::StdArc::Label, BaseFloat> e(arc.ilabel, arc.weight.Value());
//
//		heap.push(e);
//
//		kk++;
//	}
//
//
//	for (; !aiter.Done(); aiter.Next()) {
//
//		const fst::StdArc &arc = aiter.Value();
//		if (arc.olabel == eps_label | arc.olabel == unk_label)
//			continue;
//		if (arc.weight.Value() < heap.top().second) {
//			pair<fst::StdArc::Label, BaseFloat> e(arc.ilabel, arc.weight.Value());
//			heap.pop();
//			heap.push(e);
//		}
//	}
//	int size = heap.size();
//	for (kk = 0; kk < size; kk++) {
//		predictions.push_back(heap.top());
//		heap.pop();
//	}
//
//	reverse(predictions.begin(), predictions.end());
//	std::vector<string> result;
//	cout << "predictions word......"<<endl;
//	for (kk = 0; kk < size; kk++) {
//		string s = osym->Find(predictions[kk].first);
//		result.push_back(s);
//		cout << s << ", "; // << predictions[kk].second << ", ";
//	}
//	cout << endl;
//
//	return result;

}
