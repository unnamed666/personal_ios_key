#ifndef __KSingleton_h__
#define __KSingleton_h__

#include <pthread.h>

template <typename T>
class KSingleton
{
protected:
	KSingleton() : m_pObject(NULL)
	{
		pthread_mutex_init(&m_cs, NULL);
	}

	~KSingleton()
	{
		if (m_pObject)
			delete m_pObject;

		m_pObject = NULL;
		
		pthread_mutex_destroy(&m_cs);
	}

	K_BOOL Initialize()
	{
		K_BOOL bReturn = FALSE;

		if (!m_pObject)
		{
			pthread_mutex_lock(&m_cs);

			if (!m_pObject)
			{
                T* pObj = new T;
				bReturn = pObj->Initialize();
				if (!bReturn)
				{
					delete pObj;
					pObj = NULL;
					bReturn = FALSE;
                } else {
                    m_pObject = pObj;
                    bReturn = TRUE;
                }
			}

			pthread_mutex_unlock(&m_cs);
		}
	
		return bReturn;
	}

public:
	static T* Instance()
	{
		static KSingleton<T> s_singletonT;
		

		if (!s_singletonT.m_pObject)
			s_singletonT.Initialize();
		

		return s_singletonT.m_pObject;
	}

private:
	pthread_mutex_t m_cs;

	T* m_pObject;
};

#endif
