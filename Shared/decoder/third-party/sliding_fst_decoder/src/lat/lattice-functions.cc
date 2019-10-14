// lat/lattice-functions.cc

// Copyright 2009-2011  Saarland University (Author: Arnab Ghoshal)
//           2012-2013  Johns Hopkins University (Author: Daniel Povey);  Chao Weng;
//                      Bagher BabaAli
//                2013  Cisco Systems (author: Neha Agrawal) [code modified
//                      from original code in ../gmmbin/gmm-rescore-lattice.cc]
//                2014  Guoguo Chen

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


#include "lat/lattice-functions.h"
//#include "hmm/transition-model.h"
#include "util/stl-utils.h"
#include "base/kaldi-math.h"
//#include "hmm/hmm-utils.h"

namespace kaldi {

using std::map;
using std::vector;

template<class LatType>  // could be Lattice or CompactLattice
bool PruneLattice(BaseFloat beam, LatType *lat) {
  typedef typename LatType::Arc Arc;
  typedef typename Arc::Weight Weight;
  typedef typename Arc::StateId StateId;

  KALDI_ASSERT(beam > 0.0);
  if (!lat->Properties(fst::kTopSorted, true)) {
    if (fst::TopSort(lat) == false) {
      KALDI_WARN << "Cycles detected in lattice";
      return false;
    }
  }
  // We assume states before "start" are not reachable, since
  // the lattice is topologically sorted.
  int32 start = lat->Start();
  int32 num_states = lat->NumStates();
  if (num_states == 0) return false;
  std::vector<double> forward_cost(num_states,
                                   std::numeric_limits<double>::infinity());  // viterbi forward.
  forward_cost[start] = 0.0; // lattice can't have cycles so couldn't be
  // less than this.
  double best_final_cost = std::numeric_limits<double>::infinity();
  // Update the forward probs.
  // Thanks to Jing Zheng for finding a bug here.
  for (int32 state = 0; state < num_states; state++) {
    double this_forward_cost = forward_cost[state];
    for (fst::ArcIterator<LatType> aiter(*lat, state);
         !aiter.Done();
         aiter.Next()) {
      const Arc &arc(aiter.Value());
      StateId nextstate = arc.nextstate;
      KALDI_ASSERT(nextstate > state && nextstate < num_states);
      double next_forward_cost = this_forward_cost +
          ConvertToCost(arc.weight);
      if (forward_cost[nextstate] > next_forward_cost)
        forward_cost[nextstate] = next_forward_cost;
    }
    Weight final_weight = lat->Final(state);
    double this_final_cost = this_forward_cost +
        ConvertToCost(final_weight);
    if (this_final_cost < best_final_cost)
      best_final_cost = this_final_cost;
  }
  int32 bad_state = lat->AddState(); // this state is not final.
  double cutoff = best_final_cost + beam;

  // Go backwards updating the backward probs (which share memory with the
  // forward probs), and pruning arcs and deleting final-probs.  We prune arcs
  // by making them point to the non-final state "bad_state".  We'll then use
  // Trim() to remove unnecessary arcs and states.  [this is just easier than
  // doing it ourselves.]
  std::vector<double> &backward_cost(forward_cost);
  for (int32 state = num_states - 1; state >= 0; state--) {
    double this_forward_cost = forward_cost[state];
    double this_backward_cost = ConvertToCost(lat->Final(state));
    if (this_backward_cost + this_forward_cost > cutoff
        && this_backward_cost != std::numeric_limits<double>::infinity())
      lat->SetFinal(state, Weight::Zero());
    for (fst::MutableArcIterator<LatType> aiter(lat, state);
         !aiter.Done();
         aiter.Next()) {
      Arc arc(aiter.Value());
      StateId nextstate = arc.nextstate;
      KALDI_ASSERT(nextstate > state && nextstate < num_states);
      double arc_cost = ConvertToCost(arc.weight),
          arc_backward_cost = arc_cost + backward_cost[nextstate],
          this_fb_cost = this_forward_cost + arc_backward_cost;
      if (arc_backward_cost < this_backward_cost)
        this_backward_cost = arc_backward_cost;
      if (this_fb_cost > cutoff) { // Prune the arc.
        arc.nextstate = bad_state;
        aiter.SetValue(arc);
      }
    }
    backward_cost[state] = this_backward_cost;
  }
  fst::Connect(lat);
  return (lat->NumStates() > 0);
}

// instantiate the template for lattice and CompactLattice.
template bool PruneLattice(BaseFloat beam, Lattice *lat);
template bool PruneLattice(BaseFloat beam, CompactLattice *lat);

}  // namespace kaldi
