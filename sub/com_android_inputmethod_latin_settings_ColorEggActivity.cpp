//
// Created by Administrator on 2017/3/17.
//

#include "com_android_inputmethod_latin_settings_ColorEggActivity.h"

#define LOG_TAG "LatinIME: jni: Session"
#include "defines.h"
#include "dictionary/property/ngram_context.h"
#include "jni_common.h"
#include "suggest/core/session/dic_traverse_session.h"

namespace latinime {

    static void latinime_Keyboard_nativeTestCrash(JNIEnv* env, jobject obj){
        char *ptr = nullptr; *ptr = 1;
    }

    static const JNINativeMethod sMethods[] = {
            {
                    const_cast<char *>("nativeTestCrash"),
                    const_cast<char *>("()V"),
                    reinterpret_cast<void *>(latinime_Keyboard_nativeTestCrash)
            }
    };

    int register_ColorEggActivity(JNIEnv *env) {
        const char *const kClassPathName = "com/android/inputmethod/latin/settings/ColorEggActivity";
        return registerNativeMethods(env, kClassPathName, sMethods, NELEMS(sMethods));
    }

} // namespace latinime
