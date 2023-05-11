package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.workbench.domain.ClueActivityRelation;
import com.bjpowernode.crm.workbench.domain.Contacts;
import com.bjpowernode.crm.workbench.domain.ContactsActivityRelation;
import com.bjpowernode.crm.workbench.domain.ContactsRemark;

import java.util.List;
import java.util.Map;

public interface ContactsService {
    List<Contacts> queryContactsByFullName(String fullname);

    String queryContactsFullNameById(String id);

    int saveCreateContacts(Map<String,Object> map);

    List<Contacts> queryContactsByConditionForPage(Map<String,Object> map);

    int queryCountOfContactsByCondition(Map<String,Object> map);

    Contacts queryContactsById(String id);

    int updateContacts(Contacts contacts);

    int saveDeleteContacts(String[] ids);

    Contacts queryContactsByIdForDetail(String id);

    List<ContactsRemark> queryContactsRemarkByContactsId(String id);

    String[] queryActivityIdByContactsId(String id);

    int saveCreateContactsRemark(ContactsRemark contactsRemark);

    int saveEditContactsRemark(ContactsRemark contactsRemark);

    int saveDeleteContactsRemarkById(String id);

    int saveCreateContactsActivityRelationByList(List<ContactsActivityRelation> list);

    int saveDeleteContactsActivityRelationByActivityIdContactsId(ContactsActivityRelation relation);

    List<Contacts> queryContactsByCustomerId(String customerId);

    int saveDeleteContacts(String id);
}
