/*
 * ios_decodable.cc
 *
 *  Created on: Jun 21, 2017
 *      Author: jn
 */

#include "ios_decodable_test.h"
#ifdef TENSOR
bool IOSDecodableTest::SetFrameLogLikelyhood(const Eigen::TensorMap<Eigen::Tensor<float, 1, Eigen::RowMajor>,Eigen::Aligned> logit,int seq_len,int class_num){//30*28

	decodable->ApplyNewLogit(logit,seq_len,class_num);
	return true;

}

#else
bool IOSDecodableTest::SetFrameLogLikelyhood(string str){//30*28
	decodable->from_string(str);
	return true;

}
#endif
DecodableSlidingDict * IOSDecodableTest::GetRawKaldiDecodable(){

	return this->decodable;

}





