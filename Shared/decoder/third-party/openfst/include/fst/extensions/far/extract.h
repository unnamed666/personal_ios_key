// See www.openfst.org for extensive documentation on this weighted
// finite-state transducer library.
//
// Extracts component FSTs from an finite-state archive.

#ifndef FST_EXTENSIONS_FAR_EXTRACT_H_
#define FST_EXTENSIONS_FAR_EXTRACT_H_

#include <string>
#include <vector>

#include <fst/extensions/far/far.h>

namespace fst {

template <class Arc>
inline void FarWriteFst(const Fst<Arc> *fst, string key, string *okey,
                        int *nrep, int32 generate_filenames, int i,
                        const string &filename_prefix,
                        const string &filename_suffix) {
  if (key == *okey) {
    ++*nrep;
  } else {
    *nrep = 0;
  }
  *okey = key;
  string ofilename;
  if (generate_filenames) {
    std::ostringstream tmp;
    tmp.width(generate_filenames);
    tmp.fill('0');
    tmp << i;
    ofilename = tmp.str();
  } else {
    if (*nrep > 0) {
      std::ostringstream tmp;
      tmp << '.' << nrep;
      key.append(tmp.str().data(), tmp.str().size());
    }
    ofilename = key;
  }
  fst->Write(filename_prefix + ofilename + filename_suffix);
}

template <class Arc>
void FarExtract(const std::vector<string> &ifilenames, int32 generate_filenames,
                const string &keys, const string &key_separator,
                const string &range_delimiter, const string &filename_prefix,
                const string &filename_suffix) {
  FarReader<Arc> *far_reader = FarReader<Arc>::Open(ifilenames);
  if (!far_reader) return;
  string okey;
  int nrep = 0;
  std::vector<char *> key_vector;
  // User has specified a set of FSTs to extract, where some of these may in
  // fact be ranges.
  if (!keys.empty()) {
    auto *keys_cstr = new char[keys.size() + 1];
    strcpy(keys_cstr, keys.c_str());
    SplitToVector(keys_cstr, key_separator.c_str(), &key_vector, true);
    int i = 0;
    for (size_t k = 0; k < key_vector.size(); ++k, ++i) {
      string key = key_vector[k];
      auto *key_cstr = new char[key.size() + 1];
      strcpy(key_cstr, key.c_str());
      std::vector<char *> range_vector;
      SplitToVector(key_cstr, range_delimiter.c_str(), &range_vector, false);
      if (range_vector.size() == 1) {  // Not a range
        if (!far_reader->Find(key)) {
          LOG_FST(ERROR) << "FarExtract: Cannot find key " << key;
          return;
        }
        const auto *fst = far_reader->GetFst();
        FarWriteFst(fst, key, &okey, &nrep, generate_filenames, i,
                    filename_prefix, filename_suffix);
      } else if (range_vector.size() == 2) {  // A legal range
        string begin_key = range_vector[0];
        string end_key = range_vector[1];
        if (begin_key.empty() || end_key.empty()) {
          LOG_FST(ERROR) << "FarExtract: Illegal range specification " << key;
          return;
        }
        if (!far_reader->Find(begin_key)) {
          LOG_FST(ERROR) << "FarExtract: Cannot find key " << begin_key;
          return;
        }
        for (; !far_reader->Done(); far_reader->Next(), ++i) {
          const auto &ikey = far_reader->GetKey();
          if (end_key < ikey) break;
          const auto *fst = far_reader->GetFst();
          FarWriteFst(fst, ikey, &okey, &nrep, generate_filenames, i,
                      filename_prefix, filename_suffix);
        }
      } else {
        LOG_FST(ERROR) << "FarExtract: Illegal range specification " << key;
        return;
      }
      delete[] key_cstr;
    }
    delete[] keys_cstr;
    return;
  }
  // Nothing specified, so just extracts everything.
  for (size_t i = 1; !far_reader->Done(); far_reader->Next(), ++i) {
    const auto &key = far_reader->GetKey();
    const auto *fst = far_reader->GetFst();
    FarWriteFst(fst, key, &okey, &nrep, generate_filenames, i, filename_prefix,
                filename_suffix);
  }
  return;
}

}  // namespace fst

#endif  // FST_EXTENSIONS_FAR_EXTRACT_H_
