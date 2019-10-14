/*
 * cmkeyboard_sliding_decoder.cc
 *
 *  Created on: Jun 30, 2017
 *      Author: jn
 */
#include "cmkeyboard_sliding_decoder.h"


CMKeyboardSlidingDecoder::CMKeyboardSlidingDecoder(const std::string* network_path,const std::string* lexictonPath,const std::string* lmPath
		,const std::string* isymFilePath,const std::string* osymFilePath, BaseFloat _beam,int32 _max_active,int32 _min_active,BaseFloat _lattice_beam){
	Init(network_path,lexictonPath,lmPath,isymFilePath,osymFilePath, _beam, _max_active, _min_active, _lattice_beam);
}

CMKeyboardSlidingDecoder::CMKeyboardSlidingDecoder(const std::string* network_path,const std::string* lexictonPath,const std::string* lmPath
                         ,const std::string* isymFilePath,const std::string* osymFilePath) {
    Init(network_path,lexictonPath,lmPath,isymFilePath,osymFilePath);
}

CMKeyboardSlidingDecoder::~CMKeyboardSlidingDecoder(){
	Release();
}

void CMKeyboardSlidingDecoder::Release(){

	if(m_decoder!=NULL){
		m_decoder->Release();
		delete m_decoder;
		m_decoder = NULL;
	}
	if(m_decodable!=NULL){
		m_decodable->Release();
		delete m_decodable;
		m_decodable = NULL;
	}
	if (m_session) {
		m_session.reset();
	}
}
//Initialize Tensorflow and FST decoder.
bool CMKeyboardSlidingDecoder::Init(const std::string* network_path,const std::string* lexictonPath,const std::string* lmPath
		,const std::string* isymFilePath,const std::string* osymFilePath, BaseFloat _beam,int32 _max_active,int32 _min_active,BaseFloat _lattice_beam){
	return InitialTensorFlow(network_path) && InitialFst(lexictonPath,lmPath,isymFilePath,osymFilePath, _beam, _max_active, _min_active, _lattice_beam);

}

bool CMKeyboardSlidingDecoder::Init(const std::string* network_path,const std::string* lexictonPath,const std::string* lmPath
                                    ,const std::string* isymFilePath,const std::string* osymFilePath){
    return InitialTensorFlow(network_path) && InitialFst(lexictonPath,lmPath,isymFilePath,osymFilePath);
    
}

//
////Perform Gesture Input neual network forward to get output logit
bool CMKeyboardSlidingDecoder::GestureNNForward(const std::vector<int>* traject,
		Eigen::TensorMap<Eigen::Tensor<float, 1, Eigen::RowMajor>,Eigen::Aligned> &output_logit
		,int *seq_len,int *class_num){//NSArray* traject = @[@24,@28,@24,@28,@20];
    std:size_t maxLen = traject->size();
    int data[maxLen];
    int data_len = (int)maxLen;

    for (int i = 0; i < maxLen ; i++) {
        data[i] = traject->at(i);
    }
    tensorflow::Tensor tensor(tensorflow::DT_INT32,
                              tensorflow::TensorShape({data_len}));


    auto input = tensor.tensor<int, 1>();
    for (int i = 0; i < maxLen; i++) {
        input(i) = data[i];
    }

    tensorflow::Tensor tensor_len(tensorflow::DT_INT32, tensorflow::TensorShape({1}));
    auto input_len = tensor_len.tensor<int, 1>();
    for (int i = 0; i < 1; i++) {
        input_len(i) = data_len;
    }

    std::string input_layer1 = "input_raw";
    std::string input_layer2 = "seq_len_input";
    std::string output_layer = "logits";
    std::vector<tensorflow::Tensor> outputs;
    tensorflow::Status run_status = m_session->Run({{input_layer1, tensor}, {input_layer2, tensor_len}},
                                                 {output_layer}, {}, &outputs);
    if (!run_status.ok()) {
        LOG(ERROR) << "Running model failed: " << run_status;
        return false;
    }

    tensorflow::string status_string = run_status.ToString();
    LOG(INFO) << "Running status_string: " << status_string;

    tensorflow::Tensor* output = &outputs[0];

    LOG(INFO) << "output dataType: " << output->dtype();
    LOG(INFO) << "output description string: " << output->DebugString();

    output_logit = output->flat<float>();//???????????//

    *seq_len = data_len;//???????
    *class_num = output_logit.size()/data_len;//??????

    return true;

}

//Perform Decode Procedure
//bool CMKeyboardSlidingDecoder::PerformDecode(const Eigen::TensorMap<Eigen::Tensor<float, 1, Eigen::RowMajor>,Eigen::Aligned> &logit,int seq_len,int class_num){
bool CMKeyboardSlidingDecoder::PerformDecode(const std::vector<int>* traject){

    std:size_t maxLen = traject->size();
    int data[maxLen];
    int data_len = (int)maxLen;
    
    for (int i = 0; i < maxLen ; i++) {
        data[i] = traject->at(i);
    }
    tensorflow::Tensor tensor(tensorflow::DT_INT32,
                              tensorflow::TensorShape({data_len}));
    
    
    auto input = tensor.tensor<int, 1>();
    for (int i = 0; i < maxLen; i++) {
        input(i) = data[i];
    }
    
    tensorflow::Tensor tensor_len(tensorflow::DT_INT32, tensorflow::TensorShape({1}));
    auto input_len = tensor_len.tensor<int, 1>();
    for (int i = 0; i < 1; i++) {
        input_len(i) = data_len;
    }
    
    std::string input_layer1 = "input_raw";
    std::string input_layer2 = "seq_len_input";
    std::string output_layer = "logits";
    std::vector<tensorflow::Tensor> outputs;
    tensorflow::Status run_status = m_session->Run({{input_layer1, tensor}, {input_layer2, tensor_len}},
                                                   {output_layer}, {}, &outputs);
    if (!run_status.ok()) {
        LOG(ERROR) << "Running model failed: " << run_status;
        return false;
    }
    
    tensorflow::string status_string = run_status.ToString();
    LOG(INFO) << "Running status_string: " << status_string;
    
    tensorflow::Tensor* output = &outputs[0];
    
    LOG(INFO) << "output dataType: " << output->dtype();
    LOG(INFO) << "output description string: " << output->DebugString();
    
    output->shape();
	m_decodable->SetFrameLogLikelyhood(output->flat<float>(), data_len, 28);
    return m_decoder->Decode(m_decodable);
}

//Get Suggestion Word Vector
std::vector<string> CMKeyboardSlidingDecoder::GetSuggestionWords(){

	return m_decoder->GetSuggestionWord();

}

//Get Prediction Word Vector
std::vector<string> CMKeyboardSlidingDecoder::GetPreditionWords(const string &user_chose_word,int k){

    return m_decoder->GetPredictWord(user_chose_word,k);//advance in g-fst.

}

//Reset Predictor when all context disappear by accident
void CMKeyboardSlidingDecoder::ResetPredictor(){
	m_decoder->ResetPredict();
}

//Reset Predictor when user type backspace.
void CMKeyboardSlidingDecoder::ResetPredictorToSpecialContext(vector<string> history_input){

	m_decoder->ResetBeforePredict(history_input);


}


//private members.
bool CMKeyboardSlidingDecoder::InitialTensorFlow(const std::string* network_path){

	if(!CheckFileExist(network_path)){
		return false;
	}

	tensorflow::SessionOptions options;
	
	// Prevent multi-threaded Ops from hanging up Session::Run
	// Refer to issue tensorflow/tensorflow#7108
	options.config.set_inter_op_parallelism_threads(1);
	options.config.set_intra_op_parallelism_threads(1);
	
	tensorflow::Session* session_pointer = nullptr;
	tensorflow::Status session_status = tensorflow::NewSession(options, &session_pointer);

	if (!session_status.ok()) {
        std::string status_string = session_status.ToString();
        cout << "Session create failed - %s", status_string.c_str();
        return false;
    }
    
    std::unique_ptr<tensorflow::Session> session(session_pointer);
    m_session = std::move(session);//?????????????//LOG(INFO) << "Session created.";

    bool b = PortableReadFileToProto(*network_path, &m_tensorflow_graph);
    cout << b << endl;

    cout << "Creating session.";
    tensorflow::Status s = m_session->Create(m_tensorflow_graph);

    if (!s.ok()) {
        cout << "Could not create TensorFlow Graph: " << s;
        return false;
    } else {
        cout << "Create TensorFlow Graph success: " << s;
    }

    return true;

}

bool CMKeyboardSlidingDecoder::InitialFst(const std::string* lexictonPath,const std::string* lmPath
		,const std::string* isymFilePath,const std::string* osymFilePath, BaseFloat _beam,int32 _max_active,int32 _min_active,BaseFloat _lattice_beam){

	m_decoder = new IOSLatticeBiglmFasterDecoder();
	m_decodable = new IOSDecodable();

	if(!m_decoder->ReadLexiconFst(*lexictonPath))//todo: in decoder the ReadLexiconFst always return true. need modify...
		return false;
    
    if(!m_decoder->ReadLmFst(*lmPath, _beam, _max_active, _min_active, _lattice_beam)){//todo: in decoder the ReadLexiconFst always return true. need modify...
    	return false;
    }
	
    if(!m_decoder->ReadIOSyms(*isymFilePath,*osymFilePath)){//todo: in decoder the ReadLexiconFst always return true. need modify...
    	return false;
    }

    if(!m_decoder->FindUniGramState()){
    	return false;
    }

    if(!m_decoder->InitDecoding()){
    	cout<<"Decoder not Ready,init fail.!"<<endl;
    	return false;
    }
    
    return true;
}

bool CMKeyboardSlidingDecoder::InitialFst(const std::string* lexictonPath,const std::string* lmPath,const std::string* isymFilePath,const std::string* osymFilePath) {
    
    m_decoder = new IOSLatticeBiglmFasterDecoder();
    m_decodable = new IOSDecodable();
    
    if(!m_decoder->ReadLexiconFst(*lexictonPath))//todo: in decoder the ReadLexiconFst always return true. need modify...
        return false;
    
    if(!m_decoder->ReadLmFst(*lmPath)){//todo: in decoder the ReadLexiconFst always return true. need modify...
        return false;
    }
    
    if(!m_decoder->ReadIOSyms(*isymFilePath,*osymFilePath)){//todo: in decoder the ReadLexiconFst always return true. need modify...
        return false;
    }
    
    if(!m_decoder->FindUniGramState()){
        return false;
    }
    
    if(!m_decoder->InitDecoding()){
        cout<<"Decoder not Ready,init fail.!"<<endl;
        return false;
    }
    
    return true;
}

bool CMKeyboardSlidingDecoder::CheckFileExist(const std::string* path){

	return true;//todo

}

bool CMKeyboardSlidingDecoder::PortableReadFileToProto(const std::string& file_name,
                             ::google::protobuf::MessageLite* proto) {
    ::google::protobuf::io::CopyingInputStreamAdaptor stream(new IfstreamInputStream(file_name));
    stream.SetOwnsCopyingStream(true);
    // TODO(jiayq): the following coded stream is for debugging purposes to allow
    // one to parse arbitrarily large messages for MessageLite. One most likely
    // doesn't want to put protobufs larger than 64MB on Android, so we should
    // eventually remove this and quit loud when a large protobuf is passed in.
    ::google::protobuf::io::CodedInputStream coded_stream(&stream);
    // Total bytes hard limit / warning limit are set to 1GB and 512MB
    // respectively.
    coded_stream.SetTotalBytesLimit(1024LL << 20, 512LL << 20);
    return proto->ParseFromCodedStream(&coded_stream);
}

//NSString* CMKeyboardSlidingDecoder::FilePathForResourceName(NSString* name, NSString* extension) {
//    NSString* file_path = [[NSBundle mainBundle] pathForResource:name ofType:extension];
//    if (file_path == NULL) {
//        LOG(FATAL) << "Couldn't find '" << [name UTF8String] << "."
//	       << [extension UTF8String] << "' in bundle.";
//    }
//    return file_path;
//}
