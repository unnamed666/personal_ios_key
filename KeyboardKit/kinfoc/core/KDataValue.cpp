#include "stdafx.h"
#include "KDataValue.h"

KKeyValue::KKeyValue(LPCTSTR szKeyName, LPBYTE pBuffer, int nSize, LPCTSTR szValueType)
{
	m_strName = szKeyName;
	m_strType = szValueType;

	if (nSize != 0)
	{
		m_vecValue.resize(nSize);
		memcpy(&m_vecValue[0], pBuffer, nSize);
	}
}

KKeyValue::KKeyValue(LPCTSTR szKeyName, LPCTSTR szValue, LPCTSTR szValueType)
{
	m_strName = szKeyName;
	m_strType = szValueType;

	int nSize = (_tcslen(szValue) + 1) * sizeof(TCHAR);
	m_vecValue.resize(nSize);
	memcpy(&m_vecValue[0], szValue, nSize);
}

LPCTSTR KKeyValue::GetName()
{
	return m_strName;
}

LPBYTE KKeyValue::GetValue()
{
	if (m_vecValue.size() == 0)
		return NULL;

	return &m_vecValue[0];
}

LPCTSTR KKeyValue::GetString()
{
	if (m_vecValue.size() == 0)
		return NULL;

	return (LPCTSTR)&m_vecValue[0];
}

int KKeyValue::GetSize()
{
	return m_vecValue.size();
}

LPCTSTR KKeyValue::GetType()
{
	return m_strType;
}

KTableValue::KTableValue()
{
	m_uTableIndex = 0;
}

KTableValue::~KTableValue()
{
	this->Clear();
}

void KTableValue::Clear(void)
{
	m_strTableName.Empty();
	m_uTableIndex = 0;

	for (int i = 0; i < m_vecKeys.size(); i++)
	{
		delete m_vecKeys[i];
	}

	m_vecKeys.clear();
}

LPCTSTR KTableValue::GetTableName(void)
{
	return m_strTableName;
}

int KTableValue::GetTableIndex(void)
{
	return m_uTableIndex;
}

int KTableValue::GetKeyCount(void)
{
	return m_vecKeys.size();
}

KKeyValue* KTableValue::GetKeyValue(int nKeyIndex)
{
	return m_vecKeys[nKeyIndex];
}

KKeyValue* KTableValue::GetKeyValue(LPCTSTR szKeyName)
{
	KKeyValue* pKeyValue = NULL;
	for (int i = 0; i < m_vecKeys.size(); i++)
	{
		pKeyValue = m_vecKeys[i];

		if (_tcsicmp(szKeyName, pKeyValue->GetName()) == 0)
		{
			return pKeyValue;
		}
	}

	return NULL;
}

void KTableValue::SetTableName(LPCTSTR szTableName)
{
	m_strTableName = szTableName;
}

void KTableValue::SetTableIndex(unsigned short uTableIndex)
{
	m_uTableIndex = uTableIndex;
}

void KTableValue::AddKeyValue(KKeyValue* pKeyValue)
{
	m_vecKeys.push_back(pKeyValue);
}
