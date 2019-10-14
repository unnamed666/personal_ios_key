// Copyright 2015 The Gemmlowp Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// test.h: shared testing helpers.

#ifndef GEMMLOWP_TEST_TEST_H_
#define GEMMLOWP_TEST_TEST_H_

#ifdef GEMMLOWP_TEST_PROFILE
#define GEMMLOWP_PROFILING
#include "../profiling/profiler.h"
#endif

#include <cstdlib>
#include <cstring>
#include <iostream>
#include <vector>

#include "../public/gemmlowp.h"

namespace gemmlowp {

inline int Random() {
  // Use ugly old rand() since this doesn't need to be high quality.
  return rand();
}

#define GEMMLOWP_STRINGIFY2(x) #x
#define GEMMLOWP_STRINGIFY(x) GEMMLOWP_STRINGIFY2(x)

#define Check(b)                                                         \
  do {                                                                   \
    ReleaseBuildAssertion(                                               \
        b, "test failed at " __FILE__ ":" GEMMLOWP_STRINGIFY(__LINE__)); \
  } while (false)

// gemmlowp itself doesn't have a Matrix class, only a MatrixMap class,
// since it only maps existing data. In tests though, we need to
// create our own matrices.
template <typename tScalar, MapOrder tOrder>
class Matrix : public MatrixMap<tScalar, tOrder> {
 public:
  typedef MatrixMap<tScalar, tOrder> Map;
  typedef MatrixMap<const tScalar, tOrder> ConstMap;
  typedef typename Map::Scalar Scalar;
  static const MapOrder Order = tOrder;
  using Map::kOrder;
  using Map::rows_;
  using Map::cols_;
  using Map::stride_;
  using Map::data_;

 public:
  Matrix() : Map(nullptr, 0, 0, 0) {}

  Matrix(int rows, int cols) : Map(nullptr, 0, 0, 0) { Resize(rows, cols); }

  Matrix(const Matrix& other) : Map(nullptr, 0, 0, 0) { *this = other; }

  Matrix& operator=(const Matrix& other) {
    Resize(other.rows_, other.cols_);
    std::memcpy(data_, other.data_, size() * sizeof(Scalar));
    return *this;
  }

  friend bool operator==(const Matrix& a, const Matrix& b) {
    return a.rows_ == b.rows_ && a.cols_ == b.cols_ &&
           !std::memcmp(a.data_, b.data_, a.size());
  }

  void Resize(int rows, int cols) {
    rows_ = rows;
    cols_ = cols;
    stride_ = kOrder == MapOrder::ColMajor ? rows : cols;
    storage.resize(size());
    data_ = storage.data();
  }

  int size() const { return rows_ * cols_; }

  Map& map() { return *static_cast<Map*>(this); }

  ConstMap const_map() const { return ConstMap(data_, rows_, cols_, stride_); }

 protected:
  std::vector<Scalar> storage;
};

template <typename MatrixType>
void MakeRandom(MatrixType* m, int bits) {
  typedef typename MatrixType::Scalar Scalar;
  const Scalar mask = (1 << bits) - 1;
  for (int c = 0; c < m->cols(); c++) {
    for (int r = 0; r < m->rows(); r++) {
      (*m)(r, c) = Random() & mask;
    }
  }
}

template <typename MatrixType>
void MakeConstant(MatrixType* m, typename MatrixType::Scalar val) {
  for (int c = 0; c < m->cols(); c++) {
    for (int r = 0; r < m->rows(); r++) {
      (*m)(r, c) = val;
    }
  }
}

template <typename MatrixType>
void MakeZero(MatrixType* m) {
  MakeConstant(m, 0);
}

}  // namespace gemmlowp

#endif  // GEMMLOWP_TEST_TEST_H_
