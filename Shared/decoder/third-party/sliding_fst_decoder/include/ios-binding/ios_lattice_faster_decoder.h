/*
 * ios_lattice_faster_decoder.h
 *
 *  Created on: Jun 21, 2017
 *      Author: jn
 */

#ifndef IOS_LATTICE_FASTER_DECODER_H_
#define IOS_LATTICE_FASTER_DECODER_H_

#include <iostream>
#include <fst/symbol-table.h>
#include "decoder/decodable_sliding_dict.h"
#include "decoder/lattice-faster-decoder.h"
#include "fstext/fstext-utils-inl.h"
#include "ios_decodable.h"
using namespace std;
//using namespace kaldi;

#define EPSILON_OF_WORDSYMS 0
class IOSLatticeFasterDecoder{
	typedef CompactLatticeArc::StateId StateId;
public:
	IOSLatticeFasterDecoder(){
		fst = NULL;
		decoder = NULL;
	}
	void Release(){
		if(fst!=NULL){
			delete fst;
		}
		if(decoder!=NULL){
			delete decoder;
		}
		if(osym!=NULL){
			delete osym;
		}
	}
	bool ReadFst();//string &fstname
	bool DecoderReadyToUse(){return decoder!=NULL;}
	bool Decode(IOSDecodable *decodable);
	std::list<string> GetNbestWord();
	double compute_duration(timespec start, timespec end);
private:
	fst::Fst<fst::StdArc> 	*fst;
	LatticeFasterDecoder 	*decoder;
	fst::SymbolTable *osym;
};



#endif /* IOS_LATTICE_FASTER_DECODER_H_ */
