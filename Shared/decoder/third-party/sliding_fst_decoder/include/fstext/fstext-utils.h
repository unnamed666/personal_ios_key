// fstext/fstext-utils.h

// Copyright 2009-2011  Microsoft Corporation
//           2012-2013  Johns Hopkins University (Author: Daniel Povey)
//                2013  Guoguo Chen
//                2014  Telepoint Global Hosting Service, LLC. (Author: David Snyder)

// See ../../COPYING for clarification regarding multiple authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
// THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
// WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
// MERCHANTABLITY OR NON-INFRINGEMENT.
// See the Apache 2 License for the specific language governing permissions and
// limitations under the License.

#ifndef KALDI_FSTEXT_FSTEXT_UTILS_H_
#define KALDI_FSTEXT_FSTEXT_UTILS_H_
#include <algorithm>
#include <map>
#include <set>
#include <vector>
#include <fst/fstlib.h>
#include <fst/fst-decl.h>
//#include "fstext/determinize-star.h"  // ex:
//#include "fstext/remove-eps-local.h"  // ex:
#include "base/kaldi-common.h" // for error reporting macros.
//#include "util/text-utils.h" // for SplitStringToVector  // ex:
#include "fst/script/print-impl.h"

namespace fst {


/// This function converts an FST with a special structure, which is
/// output by the OpenFst functions ShortestPath and RandGen, and converts
/// them into a vector of separate FSTs.  This special structure is that
/// the only state that has more than one (arcs-out or final-prob) is the
/// start state.  fsts_out is resized to the appropriate size.
template<class Arc>
void ConvertNbestToVector(const Fst<Arc> &fst,
                          vector<VectorFst<Arc> > *fsts_out);


} // end namespace fst


#include "fstext/fstext-utils-inl.h"

#endif
