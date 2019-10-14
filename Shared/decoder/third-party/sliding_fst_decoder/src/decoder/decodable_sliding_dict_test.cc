/*
 * decodable_sliding_dict.cc
 *
 *  Created on: Jun 19, 2017
 *      Author: jn
 */
#include <string>

#include "decoder/decodable_sliding_dict_test.h"

namespace kaldi {

DecodableSlidingDictTest::DecodableSlidingDictTest(const fst::SymbolTable *isym) {
	_symbols = isym;
}

void DecodableSlidingDictTest::from_string(string instr) {
	_frames.clear();

	for (int ii = 0; ii < instr.size(); ii++) {
		string c = instr.substr(ii, 1);
		if (c == " ") {
			c = "<space>";
		}
		if (c == "-") {
			c = "<ctc_space>";
		}
		_frames.push_back(_symbols->Find(c));
	}
}

int64 DecodableSlidingDictTest::get_frame(int32 frame) {
	return _frames.at(frame);
}

int32 DecodableSlidingDictTest::NumIndices() const {
	return _frames.size();
}

BaseFloat DecodableSlidingDictTest::LogLikelihood(int32 frame, int32 index) {
	BaseFloat lll;
	if (get_frame(frame) == index) {
		if (_symbols->Find(index) == "<space>") {
			return -0.000001;
		}
		return -0.1054;
	} else {
		if (_symbols->Find(get_frame(frame)) == "<space>") {
			return -1000000;
		}
		return -4.6052; //-6.2146;
	}
}

bool DecodableSlidingDictTest::IsLastFrame(int32 frame) const {
	if (_frames.size() == frame + 1) {
		return 1;
	} else {
		return 0;
	}
}

} // namespace
