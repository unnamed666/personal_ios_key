/*
 * Copyright (C) 2014 The Android Open Source Project
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

#ifndef LATINIME_SUGGESTED_WORD_H
#define LATINIME_SUGGESTED_WORD_H

#include <vector>

#include "defines.h"
#include "suggest/core/dictionary/dictionary.h"

namespace latinime {

class SuggestedWord {
 public:
    class Comparator {
     public:
        bool operator()(const SuggestedWord &left, const SuggestedWord &right) {
            if (left.getScore() != right.getScore()) {
                return left.getScore() > right.getScore();
            }
            int leftTimestamp = left.getTimestamp();
            int rightTimestamp = right.getTimestamp();
            if(leftTimestamp != NOT_A_TIMESTAMP && rightTimestamp != NOT_A_TIMESTAMP && leftTimestamp != rightTimestamp) {
                return leftTimestamp > rightTimestamp;
            }
            return left.getCodePointCount() < right.getCodePointCount();
        }

     private:
        DISALLOW_ASSIGNMENT_OPERATOR(Comparator);
    };

    SuggestedWord(const int *const codePoints, const int codePointCount,
            const int score, const int type, const int indexToPartialCommit,
            const int autoCommitFirstWordConfidence)
            : mCodePoints(codePoints, codePoints + codePointCount), mScore(score),
              mType(type), mIndexToPartialCommit(indexToPartialCommit),
              mAutoCommitFirstWordConfidence(autoCommitFirstWordConfidence), mTimestamp(NOT_A_TIMESTAMP) {}

    SuggestedWord(const int *const codePoints, const int codePointCount,
                  const int score, const int type, const int indexToPartialCommit,
                  const int autoCommitFirstWordConfidence, const int timestamp)
            : mCodePoints(codePoints, codePoints + codePointCount), mScore(score),
              mType(type), mIndexToPartialCommit(indexToPartialCommit),
              mAutoCommitFirstWordConfidence(autoCommitFirstWordConfidence), mTimestamp(timestamp) {}

    const int *getCodePoint() const {
        return &mCodePoints.at(0);
    }

    int getCodePointCount() const {
        return mCodePoints.size();
    }

    int getScore() const {
        return mScore;
    }

    int getType() const {
        return mType;
    }

    int getIndexToPartialCommit() const {
        return mIndexToPartialCommit;
    }

    int getAutoCommitFirstWordConfidence() const {
        return mAutoCommitFirstWordConfidence;
    }

    int getTimestamp() const {
        return mTimestamp;
    }

 private:
    DISALLOW_DEFAULT_CONSTRUCTOR(SuggestedWord);

    std::vector<int> mCodePoints;
    int mScore;
    int mType;
    int mIndexToPartialCommit;
    int mAutoCommitFirstWordConfidence;
    int mTimestamp;
};
} // namespace latinime
#endif /* LATINIME_SUGGESTED_WORD_H */
