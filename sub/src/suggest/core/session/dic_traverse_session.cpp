/*
 * Copyright (C) 2012 The Android Open Source Project
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

#include "suggest/core/session/dic_traverse_session.h"

#include "defines.h"
#include "dictionary/interface/dictionary_header_structure_policy.h"
#include "dictionary/interface/dictionary_structure_with_buffer_policy.h"
#include "dictionary/property/ngram_context.h"
#include "suggest/core/dictionary/dictionary.h"

namespace latinime {

// 256K bytes threshold is heuristically used to distinguish dictionaries containing many unigrams
// (e.g. main dictionary) from small dictionaries (e.g. contacts...)
const int DicTraverseSession::DICTIONARY_SIZE_THRESHOLD_TO_USE_LARGE_CACHE_FOR_SUGGESTION =
        256 * 1024;

void DicTraverseSession::init(const Dictionary *const dictionary,
        const NgramContext *const ngramContext, const SuggestOptions *const suggestOptions) {
    mDictionary = dictionary;
    mMultiWordCostMultiplier = getDictionaryStructurePolicy()->getHeaderStructurePolicy()
            ->getMultiWordCostMultiplier();
    mSuggestOptions = suggestOptions;
    mPrevWordIdCount = ngramContext->getPrevWordIds(getDictionaryStructurePolicy(),
            &mPrevWordIdArray, true /* tryLowerCaseSearch */).size();
}

void DicTraverseSession::setupForGetSuggestions(const ProximityInfo *pInfo,
        const int *inputCodePoints, const int inputSize, const int *const inputXs,
        const int *const inputYs, const int *const times, const int *const pointerIds,
        const float maxSpatialDistance, const int maxPointerCount) {
    mProximityInfo = pInfo;
    mMaxPointerCount = maxPointerCount;

    bool isGesture = mSuggestOptions->isGesture();
    initializeProximityInfoStates(inputCodePoints, inputXs, inputYs, times, pointerIds, inputSize,
            maxSpatialDistance, isGesture ? MAX_POINTER_COUNT_G : maxPointerCount);

    if(isGesture) {
        int size = mProximityInfoStates[0].getMostProbableStringSize();
        int* codePoints = new int[size];
        int* sampledXs = new int[size];
        int* sampledYs = new int[size];

        mProximityInfoStates[0].getMostProbableString(codePoints, size);
        mProximityInfoStates[0].getMostProbableStringXs(sampledXs, size);
        mProximityInfoStates[0].getMostProbableStringYs(sampledYs, size);
        initializeProximityInfoStates(codePoints, sampledXs, sampledYs, times, pointerIds, size, maxSpatialDistance, maxPointerCount);

        delete[] codePoints;
        delete[] sampledXs;
        delete[] sampledYs;
    }
}

const DictionaryStructureWithBufferPolicy *DicTraverseSession::getDictionaryStructurePolicy()
        const {
    return mDictionary->getDictionaryStructurePolicy();
}

void DicTraverseSession::resetCache(const int thresholdForNextActiveDicNodes, const int maxWords) {
    mDicNodesCache.reset(thresholdForNextActiveDicNodes /* nextActiveSize */,
            maxWords /* terminalSize */);
    mMultiBigramMap.clear();
}

void DicTraverseSession::initializeProximityInfoStates(const int *const inputCodePoints,
        const int *const inputXs, const int *const inputYs, const int *const times,
        const int *const pointerIds, const int inputSize, const float maxSpatialDistance,
        const int maxPointerCount) {
    ASSERT(1 <= maxPointerCount && maxPointerCount <= MAX_POINTER_COUNT_G);
    mInputSize = 0;
    mProximityInfoStates[0].initInputParams(0, maxSpatialDistance, getProximityInfo(),
                                            inputCodePoints, inputSize, inputXs, inputYs, times, pointerIds,
            // Right now the line below is trying to figure out whether this is a gesture by
            // looking at the pointer count and assuming whatever is above the cutoff is
            // a gesture and whatever is below is type. This is hacky and incorrect, we
            // should pass the correct information instead.
                                            maxPointerCount == MAX_POINTER_COUNT_G,
                                            getDictionaryStructurePolicy()->getHeaderStructurePolicy()->getLocale());
    mInputSize += mProximityInfoStates[0].size();
    /*for (int i = 0; i < maxPointerCount; ++i) {
        mProximityInfoStates[i].initInputParams(i, maxSpatialDistance, getProximityInfo(),
                inputCodePoints, inputSize, inputXs, inputYs, times, pointerIds,
                // Right now the line below is trying to figure out whether this is a gesture by
                // looking at the pointer count and assuming whatever is above the cutoff is
                // a gesture and whatever is below is type. This is hacky and incorrect, we
                // should pass the correct information instead.
                maxPointerCount == MAX_POINTER_COUNT_G,
                getDictionaryStructurePolicy()->getHeaderStructurePolicy()->getLocale());
        mInputSize += mProximityInfoStates[i].size();
    }*/
}

    void DicTraverseSession::intGestureSampledData(JNIEnv *env, jobject data, jint inputsize) {
        int siSize = mProximityInfoStates[0].size();
        int mpSize = mProximityInfoStates[0].getMostProbableStringSize();
        jclass instance = env->GetObjectClass(data);
        jfieldID  scField = env->GetFieldID(instance, "mSampledPointsCount", "I");
        jfieldID  mpcField = env->GetFieldID(instance, "mMostProbablePointsCount", "I");

        //jfieldID  siCField = env->GetFieldID(instance, "mSampledInputCodes", "[I");
        jfieldID  siXField = env->GetFieldID(instance, "mSampledInputXs", "[I");
        jfieldID  siYField = env->GetFieldID(instance, "mSampledInputYs", "[I");
        jfieldID  mpXField = env->GetFieldID(instance, "mMostProbablePointsInputXs", "[I");
        jfieldID  mpYField = env->GetFieldID(instance, "mMostProbablePointsInputYs", "[I");
        jfieldID  mpsField = env->GetFieldID(instance, "mMostProbableString", "[I");

        //jintArray siCArray = (jintArray)env->GetObjectField(data, siCField);
        jintArray siXArray = (jintArray)env->GetObjectField(data, siXField);
        jintArray siYArray = (jintArray)env->GetObjectField(data, siYField);
        jintArray mpXArray = (jintArray)env->GetObjectField(data, mpXField);
        jintArray mpYArray = (jintArray)env->GetObjectField(data, mpYField);
        jintArray mpsArray = (jintArray)env->GetObjectField(data, mpsField);

        //int* sampledInputCodes = new int[siSize];
        int* sampledInputXs = new int[siSize];
        int* sampledInputYs = new int[siSize];
        int* mpXs = new int[mpSize];
        int* mpYs = new int[mpSize];
        int* mpString = new int[mpSize];
        mProximityInfoStates[0].getSampledXs(sampledInputXs);
        mProximityInfoStates[0].getSampledYs(sampledInputYs);
        mProximityInfoStates[0].getMostProbableStringXs(mpXs, mpSize);
        mProximityInfoStates[0].getMostProbableStringYs(mpYs, mpSize);
        mProximityInfoStates[0].getMostProbableString(mpString, mpSize);


        env->SetIntField(data, scField, siSize);
        env->SetIntField(data, mpcField, mpSize);
        env->SetIntArrayRegion(siXArray, 0, siSize, sampledInputXs);
        env->SetIntArrayRegion(siYArray, 0, siSize, sampledInputYs);
        env->SetIntArrayRegion(mpXArray, 0, mpSize, mpXs);
        env->SetIntArrayRegion(mpYArray, 0, mpSize, mpYs);
        env->SetIntArrayRegion(mpsArray, 0, mpSize, mpString);

        delete[] sampledInputXs;
        delete[] sampledInputYs;
        delete[] mpXs;
        delete[] mpYs;
        delete[] mpString;
    }
} // namespace latinime
