/*
 * decodable_sliding_dict.h
 *
 *  Created on: Jun 19, 2017
 *      Author: jn
 */

#ifndef DECODER_DECODABLE_SLIDING_DICT_H_
#define DECODER_DECODABLE_SLIDING_DICT_H_

#include <vector>
#include <fst/fst.h>

#include "itf/decodable-itf.h"
#include "matrix/kaldi-matrix.h"
//typedef float BaseFloat;
using namespace std;
namespace kaldi {

class DecodableSlidingDict : public DecodableInterface {

public:
	 DecodableSlidingDict(const Matrix<BaseFloat> &likes): likes_(likes){ }
	 DecodableSlidingDict();

	 DecodableSlidingDict(const fst::SymbolTable *isym);
	 virtual ~DecodableSlidingDict() {}
//BEGIN
	 /// The call NumFramesReady() will return the number of frames currently available
	 /// for this decodable object.  This is for use in setups where you don't want the
	 /// decoder to block while waiting for input.  This is newly added as of Jan 2014,
	 /// and I hope, going forward, to rely on this mechanism more than IsLastFrame to
	 /// know when to stop decoding.
	 int32 NumFramesReady() const {return likes_.NumRows();}//return _frames.size();

	 /// Returns true if this is the last frame.  Frames are zero-based, so the
	 /// first frame is zero.  IsLastFrame(-1) will return false, unless the file
	 /// is empty (which is a case that I'm not sure all the code will handle, so
	 /// be careful).  Caution: the behavior of this function in an online setting
	 /// is being changed somewhat.  In future it may return false in cases where
	 /// we haven't yet decided to terminate decoding, but later true if we decide
	 /// to terminate decoding.  The plan in future is to rely more on
	 /// NumFramesReady(), and in future, IsLastFrame() would always return false
	 /// in an online-decoding setting, and would only return true in a
	 /// decoding-from-matrix setting where we want to allow the last delta or LDA
	 /// features to be flushed out for compatibility with the baseline setup.
	 bool IsLastFrame(int32 frame) const;

	 /// Returns the log likelihood, which will be negated in the decoder.
	 /// The "frame" starts from zero.  You should verify that IsLastFrame(frame-1)
	 /// returns false before calling this.
	 BaseFloat LogLikelihood(int32 frame, int32 index);

	 /// Returns the number of states in the acoustic model
	 /// (they will be indexed one-based, i.e. from 1 to NumIndices();
	 /// this is for compatibility with OpenFst).
	 int32 NumIndices() const;

	 //own features
#ifdef TENSOR
	 bool ApplyNewLogit(const Eigen::TensorMap<Eigen::Tensor<float, 1, Eigen::RowMajor>,Eigen::Aligned> logit,int rows,int cols);
#else
	 bool ApplyNewLogit(const Matrix<BaseFloat> logit,int rows,int cols);//const Matrix<BaseFloat> &likes
#endif
private:
	 const fst::SymbolTable *_symbols;
	 Matrix<BaseFloat> likes_;

};

}

#endif /* DECODER_DECODABLE_SLIDING_DICT_H_ */
