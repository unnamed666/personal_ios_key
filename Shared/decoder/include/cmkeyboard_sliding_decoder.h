/*
 * cmkeyboard_sliding_decoder.h
 *
 *  Created on: Jun 30, 2017
 *      Author: jn
 */

#ifndef CMKEYBOARD_SLIDING_DECODER_H_
#define CMKEYBOARD_SLIDING_DECODER_H_

#include <fstream>
#include <sstream>
#include <unistd.h>
#include "tensorflow/core/public/session.h"
#include "ios-binding/ios_decodable.h"
#include "ios-binding/ios_lattice_faster_decoder.h"
#include "ios-binding/ios_lattice_biglm_faster_decoder.h"

class CMKeyboardSlidingDecoder{
public:

    CMKeyboardSlidingDecoder(const std::string* network_path,const std::string* lexictonPath,const std::string* lmPath
                             ,const std::string* isymFilePath,const std::string* osymFilePath, BaseFloat _beam,int32 _max_active,int32 _min_active,BaseFloat _lattice_beam);
    CMKeyboardSlidingDecoder(const std::string* network_path,const std::string* lexictonPath,const std::string* lmPath
                             ,const std::string* isymFilePath,const std::string* osymFilePath);
	virtual ~CMKeyboardSlidingDecoder();

public:
	//Initialize Tensorflow and FST decoder.
	bool Init(const std::string* network_path,const std::string* lexictonPath,const std::string* lmPath
			,const std::string* isymFilePath,const std::string* osymFilePath, BaseFloat _beam,int32 _max_active,int32 _min_active,BaseFloat _lattice_beam);
    bool Init(const std::string* network_path,const std::string* lexictonPath,const std::string* lmPath
              ,const std::string* isymFilePath,const std::string* osymFilePath);

    
    bool InitialTensorFlow(const std::string* network_path);
    bool InitialFst(const std::string* lexictonPath,const std::string* lmPath,const std::string* isymFilePath,const std::string* osymFilePath, BaseFloat _beam,int32 _max_active,int32 _min_active,BaseFloat _lattice_beam);
    bool InitialFst(const std::string* lexictonPath,const std::string* lmPath,const std::string* isymFilePath,const std::string* osymFilePath);
    
    void createSession() {
        tensorflow::SessionOptions options;
        tensorflow::Session* session_pointer = nullptr;
        tensorflow::Status session_status = tensorflow::NewSession(options, &session_pointer);
        
        if (!session_status.ok()) {
            std::string status_string = session_status.ToString();
            cout << "Session create failed - " << status_string.c_str();
//            return false;
            }
            
            std::unique_ptr<tensorflow::Session> session(session_pointer);
            m_session = std::move(session);//?????????????//LOG(INFO) << "Session created.";
    }
    
    void readFileFromPB(const std::string* network_path) {
        PortableReadFileToProto(*network_path, &m_tensorflow_graph);
    }
    
    void setupSession() {
        tensorflow::Status s = m_session->Create(m_tensorflow_graph);
        if (!s.ok()) {
            cout << "Could not create TensorFlow Graph: " << s;
        } else {
            cout << "Create TensorFlow Graph success: " << s;
        }
    }
    
    void createObjects() {
        m_decoder = new IOSLatticeBiglmFasterDecoder();
        m_decodable = new IOSDecodable();
    }
    
    void readLEX(const std::string* lexictonPath) {
        m_decoder->ReadLexiconFst(*lexictonPath);
    }

    void readLM(const std::string* lmPath) {
        m_decoder->ReadLmFst(*lmPath);
    }
    
    void readIOSyms(const std::string* isymFilePath,const std::string* osymFilePath) {
        m_decoder->ReadIOSyms(*isymFilePath,*osymFilePath);
    }
    
    void setupObjects() {
        if(!m_decoder->FindUniGramState()){
//            return false;
        }
        
        if(!m_decoder->InitDecoding()){
            cout<<"Decoder not Ready,init fail.!"<<endl;
//            return false;
        }
    }


	//Perform Gesture Input neual network forward to get output logit
    bool GestureNNForward(const std::vector<int>* traject,
			Eigen::TensorMap<Eigen::Tensor<float, 1, Eigen::RowMajor>,Eigen::Aligned> &output_logit
			,int *seq_len,int *class_num);

	//Perform Decode Procedure
	//bool PerformDecode(const Eigen::TensorMap<Eigen::Tensor<float, 1, Eigen::RowMajor>,Eigen::Aligned> &logit,int seq_len,int class_num);
    bool PerformDecode(const std::vector<int>* traject);
    
	//Get Suggestion Word Vector
    std::vector<std::string>  GetSuggestionWords();

	//Get Prediction Word Vector
    std::vector<std::string> GetPreditionWords(const std::string &user_chose_word,int k);

	//Reset Predictor when all context disappear by accident
	void ResetPredictor();

	//Reset Predictor when user type backspace.
	void ResetPredictorToSpecialContext(std::vector<std::string> history_input);
	void Release();
private:

	bool CheckFileExist(const std::string* path);
	bool PortableReadFileToProto(const std::string& file_name,::google::protobuf::MessageLite* proto);
    std::string* FilePathForResourceName(std::string* name, std::string* extension);

private:
	//tensorflow::Session* m_session_pointer;
	std::unique_ptr<tensorflow::Session> m_session;
	tensorflow::GraphDef m_tensorflow_graph;

	IOSLatticeBiglmFasterDecoder *m_decoder;
	IOSDecodable *m_decodable;
};



namespace {
    class IfstreamInputStream : public ::google::protobuf::io::CopyingInputStream {
    public:
        explicit IfstreamInputStream(const std::string& file_name)
        : ifs_(file_name.c_str(), std::ios::in | std::ios::binary) {}
        ~IfstreamInputStream() { ifs_.close(); }
        
        int Read(void* buffer, int size) {
            if (!ifs_) {
                return -1;
            }
            ifs_.read(static_cast<char*>(buffer), size);
            return (int)ifs_.gcount();
        }
        
    private:
        std::ifstream ifs_;
    };
}  // namespace




#endif /* CMKEYBOARD_SLIDING_DECODER_H_ */
