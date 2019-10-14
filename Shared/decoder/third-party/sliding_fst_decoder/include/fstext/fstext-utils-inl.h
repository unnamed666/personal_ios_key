// fstext/fstext-utils-inl.h

// Copyright 2009-2012  Microsoft Corporation  Johns Hopkins University (Author: Daniel Povey)
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

#ifndef KALDI_FSTEXT_FSTEXT_UTILS_INL_H_
#define KALDI_FSTEXT_FSTEXT_UTILS_INL_H_
#include <cstring>
#include "base/kaldi-common.h"
//#include "util/stl-utils.h"  // ex:
//#include "util/text-utils.h" // ex:
//#include "util/kaldi-io.h"   // ex:
//#include "fstext/factor.h"   // ex:
//#include "fstext/pre-determinize.h"   // ex:
//#include "fstext/determinize-star.h"  // ex:

// ex: add by y.c.
#include "fstext/fstext-utils.h"

#include <sstream>
#include <algorithm>
#include <string>

namespace fst {

// see fstext-utils.sh for comment.
template<class Arc>
void ConvertNbestToVector(const Fst<Arc> &fst,
                          vector<VectorFst<Arc> > *fsts_out) {
  typedef typename Arc::Weight Weight;
  typedef typename Arc::StateId StateId;
  fsts_out->clear();
  StateId start_state = fst.Start();
  if (start_state == kNoStateId) return; // No output.
  size_t n_arcs = fst.NumArcs(start_state);
  bool start_is_final = (fst.Final(start_state) != Weight::Zero());
  fsts_out->reserve(n_arcs + (start_is_final ? 1 : 0));

  if (start_is_final) {
    fsts_out->resize(fsts_out->size() + 1);
    StateId start_state_out = fsts_out->back().AddState();
    fsts_out->back().SetFinal(start_state_out, fst.Final(start_state));
  }

  for (ArcIterator<Fst<Arc> > start_aiter(fst, start_state);
       !start_aiter.Done();
       start_aiter.Next()) {
    fsts_out->resize(fsts_out->size() + 1);
    VectorFst<Arc> &ofst = fsts_out->back();
    const Arc &first_arc = start_aiter.Value();
    StateId cur_state = start_state,
        cur_ostate = ofst.AddState();
    ofst.SetStart(cur_ostate);
    StateId next_ostate = ofst.AddState();
    ofst.AddArc(cur_ostate, Arc(first_arc.ilabel, first_arc.olabel,
                                first_arc.weight, next_ostate));
    cur_state = first_arc.nextstate;
    cur_ostate = next_ostate;
    while (1) {
      size_t this_n_arcs = fst.NumArcs(cur_state);
      KALDI_ASSERT(this_n_arcs <= 1); // or it violates our assumptions
                                      // about the input.
      if (this_n_arcs == 1) {
        KALDI_ASSERT(fst.Final(cur_state) == Weight::Zero());
        // or problem with ShortestPath.
        ArcIterator<Fst<Arc> > aiter(fst, cur_state);
        const Arc &arc = aiter.Value();
        next_ostate = ofst.AddState();
        ofst.AddArc(cur_ostate, Arc(arc.ilabel, arc.olabel,
                                    arc.weight, next_ostate));
        cur_state = arc.nextstate;
        cur_ostate = next_ostate;
      } else {
        KALDI_ASSERT(fst.Final(cur_state) != Weight::Zero());
        // or problem with ShortestPath.
        ofst.SetFinal(cur_ostate, fst.Final(cur_state));
        break;
      }
    }
  }
}

} // namespace fst.

#endif
