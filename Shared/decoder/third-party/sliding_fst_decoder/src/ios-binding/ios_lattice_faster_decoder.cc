/*
 * ios_lattice_faster_decoder.cc
 *
 *  Created on: Jun 21, 2017
 *      Author: jn
 */

#include "ios_lattice_faster_decoder.h"


bool IOSLatticeFasterDecoder::ReadFst(){//string &fstname//"fstLib/ctc_lexicon.fst"
	//cout<<"ReadFst"<<endl;
	fst = fst::Fst<fst::StdArc>::Read("ctc_lexicon.fst");//lexicon_opt//fstname

	const LatticeFasterDecoderConfig *config = new LatticeFasterDecoderConfig;

	decoder = new LatticeFasterDecoder(*fst, *config);

	osym = fst::SymbolTable::ReadText("word.syms");

	return true;
}

bool IOSLatticeFasterDecoder::Decode(IOSDecodable *decodable){
	//cout<<"Decode use decodable..."<<endl;
	decoder->Decode(decodable->GetRawKaldiDecodable());
	return true;
}

double IOSLatticeFasterDecoder::compute_duration(timespec start, timespec end) {
	// unit is in milisecond

	timespec diff;

	diff.tv_sec = ( end.tv_sec - start.tv_sec );
	diff.tv_nsec = ( end.tv_nsec - start.tv_nsec );
	if (diff.tv_nsec < 0) {
	    diff.tv_sec--;
	    diff.tv_nsec += 1000000000;
	}
	int usec = diff.tv_nsec + diff.tv_sec * 100000000;
	double resultTime = (double)usec / 1000000;
	return resultTime;
}

std::list<string> IOSLatticeFasterDecoder::GetNbestWord(){
#ifdef SHOW_TIME
	timespec start, end;
	clock_gettime(CLOCK_THREAD_CPUTIME_ID, &start);
#endif
	//cout<<"Get Nbest Word..."<<endl;
	CompactLattice lat;
	//decoder->GetBestPath(&lat, true);
	//decoder->GetRawLattice(&lat, true);// fst+beam+max_active+frames
	decoder->GetLattice(&lat, true);
#ifdef SHOW_TIME
	clock_gettime(CLOCK_THREAD_CPUTIME_ID, &end);
	double dur = compute_duration(start, end);
	printf("GetLattice time: %6.6lf[ms]\n", dur);
#endif
	//std::vector<Lattice> nbest_lats;
	CompactLattice nbest_lat;
    fst::ShortestPath(lat, &nbest_lat, 3);
    //lat.Write("lat_best.fst");
    //nbest_lat.Write("lat_nbest.fst");
#ifdef SHOW_TIME
    clock_gettime(CLOCK_THREAD_CPUTIME_ID, &start);
	dur = compute_duration(end, start);
	printf("ShortestPath time: %6.6lf[ms]\n", dur);
#endif
    std::vector<CompactLattice> nbest_lats;
    fst::ConvertNbestToVector(nbest_lat,&nbest_lats);
#ifdef SHOW_TIME
    clock_gettime(CLOCK_THREAD_CPUTIME_ID, &end);
	dur = compute_duration(start, end);
	printf("ConvertNbestToVector time: %6.6lf[ms]\n", dur);
#endif

	std::list<string> result;


    if (nbest_lats.empty()) {
      //cout<<"no best word find!"<<endl;
      //result.append("word1");
    } else {
    	  //cout<<"get list of nbest::"<<endl;

    	  //const fst::SymbolTable *isym = nbest_lat.InputSymbols();
    	  const fst::SymbolTable *private_osym = nbest_lat.OutputSymbols();

      	  if(osym == NULL){
	      	 return result;
      	  }


		  for (int32 k = 0; k < static_cast<int32>(nbest_lats.size()); k++) {
			  //CompactLattice nbest_clat;
			  //ConvertLattice(nbest_lats[k], &nbest_clat); // write in compact form.
			  CompactLattice single = nbest_lats[k];
			  string word;
			  for (fst::StateIterator<CompactLattice> siter(single); !siter.Done(); siter.Next()){
				  StateId state_id = siter.Value();
				  for (fst::ArcIterator<CompactLattice> aiter(single, state_id); !aiter.Done(); aiter.Next())
				  {
					  const CompactLatticeArc &arc = aiter.Value();
					  //arc.olabel;
					  //cout<<arc.olabel<<endl;
					  if(arc.olabel != EPSILON_OF_WORDSYMS){
						  //cout<<arc.olabel<<endl;
						  word += osym->Find(arc.olabel);
					  }

				  }
			  }
			  result.push_back(word);

		  }
    }
#ifdef SHOW_TIME
    clock_gettime(CLOCK_THREAD_CPUTIME_ID, &start);
	dur = compute_duration(end, start);
	printf("...... time: %6.6lf[ms]\n", dur);
    //cout << "Success." << endl;
#endif

	return result;
}



