/*
 * decodable_sliding_dict.cc
 *
 *  Created on: Jun 19, 2017
 *      Author: jn
 */
#include <string>
#include "decodable_sliding_dict.h"

namespace kaldi {

DecodableSlidingDict::DecodableSlidingDict()
{
	likes_.Resize(30,28);
	likes_.SetRandUniform();
	likes_.ApplyLog();
	//likes_.Dump();
}

DecodableSlidingDict::DecodableSlidingDict(const fst::SymbolTable *isym) {
	likes_.Resize(30,28);
	likes_.SetRandUniform();
	likes_.ApplyLog();
	//likes_.Dump();
	_symbols = isym;
}

int32 DecodableSlidingDict::NumIndices() const {
	return likes_.NumCols();
	//return _frames.size();
}

BaseFloat DecodableSlidingDict::LogLikelihood(int32 frame, int32 index) {
	//index map
	int idx;
	if(index == 127)
		idx = 27;
	else if(index>=65&&index<=90){
		idx = index-64;
	}else if(index>=97&&index<=122){
		idx = index-96;
	}else{
		idx = 0;
	}
//	return likes_(frame, idx);
	return std::log((float)likes_(frame, idx));
}

bool DecodableSlidingDict::IsLastFrame(int32 frame) const {
    KALDI_ASSERT(frame < NumFramesReady());
    return (frame == NumFramesReady() - 1);
}
#ifdef TENSOR
bool DecodableSlidingDict::ApplyNewLogit(const Eigen::TensorMap<Eigen::Tensor<float, 1, Eigen::RowMajor>,Eigen::Aligned> logit,int rows,int cols){//const Matrix<BaseFloat> &likes
	likes_.Resize(rows,cols,kUndefined);
	likes_.CopyFromTensor(logit,rows,cols);
	return true;
}
#else
bool DecodableSlidingDict::ApplyNewLogit(const Matrix<BaseFloat> logit,int rows,int cols){//const Matrix<BaseFloat> &likes
	likes_.Resize(rows,cols,kUndefined);
	likes_.CopyFromMat(logit);
	//likes_.CopyFromNumpy(logit);
	//likes_.Dump();
	return true;
}
#endif

} // namespace

