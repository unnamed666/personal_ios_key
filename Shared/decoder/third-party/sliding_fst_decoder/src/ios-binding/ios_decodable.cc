/*
 * ios_decodable.cc
 *
 *  Created on: Jun 21, 2017
 *      Author: jn
 */

#include "ios_decodable.h"
#ifdef TENSOR
bool IOSDecodable::SetFrameLogLikelyhood(const Eigen::TensorMap<Eigen::Tensor<float, 1, Eigen::RowMajor>,Eigen::Aligned> logit,int seq_len,int class_num){//30*28

	decodable->ApplyNewLogit(logit,seq_len,class_num);
	return true;

}

#else
bool IOSDecodable::SetFrameLogLikelyhood(const Matrix<BaseFloat> logit){//30*28
	int row_num = logit.NumRows();
	int col_num = logit.NumCols();

	//Matrix<BaseFloat> likes;
	//likes.Resize(row_num,col_num,kUndefined);
	//likes.CopyFromNumpy(logit);

	decodable->ApplyNewLogit(logit,row_num,col_num);
	return true;

}
#endif
DecodableSlidingDict * IOSDecodable::GetRawKaldiDecodable(){

	return this->decodable;

}





