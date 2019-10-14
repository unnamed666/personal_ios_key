/*
 * ios_decodable.h
 *
 *  Created on: Jun 21, 2017
 *      Author: jn
 */

#ifndef IOS_DECODABLE_H_
#define IOS_DECODABLE_H_
#include <fst/symbol-table.h>
#include "decoder/decodable_sliding_dict.h"
#include "decoder/lattice-faster-decoder.h"
#include "fstext/fstext-utils-inl.h"

using namespace std;
using namespace kaldi;

class IOSDecodable{
public:
	IOSDecodable(){
		decodable = NULL;
		decodable = new DecodableSlidingDict();
	}
	void Release(){
		if(decodable!=NULL){
			delete decodable;
		}
	}
#ifdef TENSOR
	bool SetFrameLogLikelyhood(const Eigen::TensorMap<Eigen::Tensor<float, 1, Eigen::RowMajor>,Eigen::Aligned> logit
			,int seq_len,int class_num);
#else
	bool SetFrameLogLikelyhood(const Matrix<BaseFloat> logit);
#endif
	DecodableSlidingDict * GetRawKaldiDecodable();
private:
	DecodableSlidingDict *decodable;
};


#endif /* IOS_DECODABLE_H_ */
