/*
 * Copyright (C) 2013 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef LATINIME_ALGORITHM_SWITCH_H
#define LATINIME_ALGORITHM_SWITCH_H

#include "../defines.h"

namespace latinime {

class AlgorithmSwitch {
 public:
    static AlgorithmSwitch& getInstance() {
        static AlgorithmSwitch sInstance;
        return sInstance;
    }

    void setUseNewAlgorithm(bool useNew);
    bool isUseNewAlgorithm();
 private:
    AlgorithmSwitch();
    bool mIsUseNewAlgorithm;
    DISALLOW_COPY_AND_ASSIGN(AlgorithmSwitch);
};


} // namespace latinime
#endif // LATINIME_ALGORITHM_SWITCH_H
