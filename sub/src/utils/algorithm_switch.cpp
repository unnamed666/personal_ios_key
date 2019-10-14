

#include "algorithm_switch.h"

namespace latinime {
    void AlgorithmSwitch::setUseNewAlgorithm(bool useNew) {
        mIsUseNewAlgorithm = useNew;
    }

    bool AlgorithmSwitch::isUseNewAlgorithm() {
        return mIsUseNewAlgorithm;
    }

    AlgorithmSwitch::AlgorithmSwitch() {
        mIsUseNewAlgorithm = true;
    }
}
