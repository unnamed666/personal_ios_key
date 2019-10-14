/*
 * test_decodable.cpp
 *
 *  Created on: Jun 9, 2017
 *      Author: yangchen
 */

#include <string>

#include "decoder/test_decodable.h"

namespace kaldi {

TestDecodable::TestDecodable(const fst::SymbolTable *isym) {
	_symbols = isym;
}

void TestDecodable::from_string(string instr) {
	_frames.clear();

	for (int ii = 0; ii < instr.size(); ii++) {
		string c = instr.substr(ii, 1);
		if (c == " ") {
			c = "<space>";
		}
		_frames.push_back(_symbols->Find(c));
	}
}

int64 TestDecodable::get_frame(int32 frame) {
	return _frames.at(frame);
}

int32 TestDecodable::NumIndices() const {
	return _frames.size();
}

BaseFloat TestDecodable::LogLikelihood(int32 frame, int32 index) {
	BaseFloat lll;
	if (get_frame(frame) == index) {
		if (_symbols->Find(index) == "<space>") {
			return -0.000001;
		}
		return -0.2231;
//		return 0;
	} else {
		if (_symbols->Find(get_frame(frame)) == "<space>") {
//			return std::numeric_limits<BaseFloat>::infinity();
			return -1000000;
		}
		return -2.3026;
//		return -1000000;
	}
}

bool TestDecodable::IsLastFrame(int32 frame) const {
	if (_frames.size() == frame + 1) {
		return 1;
	} else {
		return 0;
	}
}

} // namespace
