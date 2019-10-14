/*
 * ios_lattice_biglm_faster_decoder.h
 *
 *  Created on: Jun 22, 2017
 *      Author: jn
 */

#ifndef IOS_LATTICE_BIGLM_FASTER_DECODER_H_
#define IOS_LATTICE_BIGLM_FASTER_DECODER_H_

#include <iostream>
#include <fst/symbol-table.h>
#include "decoder/decodable_sliding_dict.h"
#include "decoder/decodable_sliding_dict_test.h"
#include "decoder/lattice-biglm-faster-decoder.h"
#include "predictor/normal-predictor.h"
#include "fstext/fstext-utils-inl.h"
#include "ios_decodable.h"
#include "ios_decodable_test.h"
#include <queue>
#include <functional>
using namespace std;
//using namespace kaldi;
#define EPSILON_OF_WORDSYMS 0
typedef CompactLatticeArc::StateId StateId;
#define EPSILON_STRING "<epsilon>"
#define UNKNOW_STRING "<unk>"
class IOSLatticeBiglmFasterDecoder{
public:

	IOSLatticeBiglmFasterDecoder();
public:

	void Release();
	bool ReadLexiconFst(const string &filename);
	bool ReadLmFst(const string &filename);
	bool ReadLmFst(const string &filename,
			  BaseFloat _beam,int32 _max_active,int32 _min_active,BaseFloat _lattice_beam,
			  int32 _prune_interval = 25,bool _determinize_lattice = true,BaseFloat _beam_delta = 0.5,BaseFloat _hash_ratio = 2.0,BaseFloat _prune_scale = 0.1);
	bool ReadIOSyms(const string&isymfilename,const string &osymfilename);
	bool FindUniGramState();
	bool InitDecoding(){
		if(DecoderReadyToUse()){
			decoder->InitDecoding();
			return true;
		}
		return false;
	}

	bool Decode(IOSDecodable *decodable);
	bool DecodeTest(IOSDecodableTest *decodable);

	std::vector<string> GetSuggestionWord();//result...
	std::vector<string> GetPredictWord(string user_chose_word,int topk);
	void ResetBeforePredict(vector<string> input);
	void ResetPredict();
private:
	bool GenerateDecoder();
	bool GenerateDecoder(
	  BaseFloat _beam,int32 _max_active,int32 _min_active,BaseFloat _lattice_beam,
	  int32 _prune_interval,bool _determinize_lattice,BaseFloat _beam_delta,BaseFloat _hash_ratio,BaseFloat _prune_scale);
	bool DecoderReadyToUse(){return decoder!=NULL;}

private:
	fst::Fst<fst::StdArc> 	*lfst;
	fst::Fst<fst::StdArc> 	*gfst;

	LatticeBiglmFasterDecoder 	*decoder;

	const fst::SymbolTable *isym;
	const fst::SymbolTable *osym;

	//new
	fst::StdArc::StateId lm_state;
	fst::StdArc::StateId unigram_state;

	fst::CacheDeterministicOnDemandFst<fst::StdArc> *cache_dfst;
	fst::BackoffDeterministicOnDemandFst<fst::StdArc> *new_lm_dfst;

	NormalPredictor *predictor;
};



#endif /* IOS_LATTICE_BIGLM_FASTER_DECODER_H_ */
