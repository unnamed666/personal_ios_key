genertate a shared library to be used by forward decoder only depend on openfst.

fst with beam-search...

decoder demo.

/*


main.cpp
*
 Created on: Jun 21, 2017
     Author: jn
*/


#include "ios-binding/ios_decodable.h"

#include "ios-binding/ios_lattice_faster_decoder.h"

#include "ios-binding/ios_lattice_biglm_faster_decoder.h"

#include "vector"

int main(){

	/****************pure l-fst***************************/

	IOSLatticeFasterDecoder *decoder1   = new IOSLatticeFasterDecoder();
	IOSDecodable *decodable1 = new IOSDecodable();
	decoder1->ReadFst();

	if(decoder1->DecoderReadyToUse()){
		//decodable->SetFrameLogLikelyhood(sample);
		decoder1->Decode(decodable1);

		std::list<string> nbest_list = decoder1->GetNbestWord();
		cout<<"-----------only with LFST+Suggetion Word:-----------"<<endl;
		for(std::list<std::string>::const_iterator i = nbest_list.begin(); i != nbest_list.end(); ++i)
		{
			 printf("%s\n", i->c_str());
		}

	}else{
		cout<<"Decoder not Ready!"<<endl;
	}

	/******************l-fst+g-fst*************************/

	IOSLatticeBiglmFasterDecoder *decoder = new IOSLatticeBiglmFasterDecoder();

	string lexicon = "ctc_lexicon.fst";//lexicon_opt.fst--
	decoder->ReadLexiconFst(lexicon);

	string lm = "lm_not_compact.mod";
	decoder->ReadLmFst(lm);

	string isym = "char.syms";
	string osym = "word.syms";
	decoder->ReadIOSyms(isym,osym);

	decoder->FindUniGramState();
	cout<<"----------L-fst & G-fst test:-----------"<<endl;
	if(decoder->InitDecoding()){

		//decodable->SetFrameLogLikelyhood(sample);

		decoder->Decode(decodable1);//reset-lm-state. and decode..
		std::vector<string> nbest_list = decoder->GetSuggestionWord();
		cout<<"##########Sliding Suggestion word:##########"<<endl;
		for(std::vector<std::string>::const_iterator i = nbest_list.begin(); i != nbest_list.end(); ++i)
		{
			 printf("%s\n", i->c_str());
		}
		//wait user chose..

		cout<<"##########Assume user chose word: \t"<<nbest_list.at(0).c_str()<<endl;

		cout<<"##########Prediction word:##########"<<endl;
		std::vector<string> pred_list = decoder->GetPredictWord(string(nbest_list.at(0).c_str()),3);//advance in g-fst.
		for(std::vector<std::string>::const_iterator i = pred_list.begin(); i != pred_list.end(); ++i)
		{
			 printf("%s\n", i->c_str());
		}

	}else{

		cout<<"Decoder not Ready,init fail.!"<<endl;

	}

	decoder->Release();

}