package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.commons.contants.Contants;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.workbench.domain.Contacts;
import com.bjpowernode.crm.workbench.domain.ContactsActivityRelation;
import com.bjpowernode.crm.workbench.domain.ContactsRemark;
import com.bjpowernode.crm.workbench.domain.Customer;
import com.bjpowernode.crm.workbench.mapper.ContactsActivityRelationMapper;
import com.bjpowernode.crm.workbench.mapper.ContactsMapper;
import com.bjpowernode.crm.workbench.mapper.ContactsRemarkMapper;
import com.bjpowernode.crm.workbench.mapper.CustomerMapper;
import com.bjpowernode.crm.workbench.service.ContactsService;
import com.bjpowernode.crm.workbench.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Map;

@Service("contactsService")
public class ContactsServiceImpl implements ContactsService {
    @Autowired
    private ContactsMapper contactsMapper;
    @Autowired
    private CustomerMapper customerMapper;
    @Autowired
    private ContactsRemarkMapper contactsRemarkMapper;
    @Autowired
    private ContactsActivityRelationMapper contactsActivityRelationMapper;
    @Override
    public List<Contacts> queryContactsByFullName(String fullname) {
        return contactsMapper.selectContactsByFullName(fullname);
    }

    @Override
    public String queryContactsFullNameById(String id) {
        return contactsMapper.selectContactsFullNameById(id);
    }

    @Override
    public int saveCreateContacts(Map<String,Object> map) {
        User user = (User) map.get(Contants.SESSION_USER);
        String customerName = (String) map.get("customerName");
        Customer customer = customerMapper.selectCustomerByCustomerName(customerName);
        if(customer==null){
            customer=new Customer();
            customer.setCreateBy(user.getId());
            customer.setId(UUIDUtils.getUUID());
            customer.setCreateTime(DateUtils.formateDateTime(new Date()));
            customer.setName(customerName);
            customer.setOwner(user.getId());
            customerMapper.insertCustomer(customer);
        }
        Contacts contacts = new Contacts();
        contacts.setId(UUIDUtils.getUUID());
        contacts.setCreateTime(DateUtils.formateDateTime(new Date()));
        contacts.setCreateBy(user.getId());
        contacts.setContactSummary((String)map.get("contactSummary"));
        contacts.setAddress((String)map.get("address"));
        contacts.setAppellation((String)map.get("appellation"));
        contacts.setNextContactTime((String)map.get("nextContactTime"));
        contacts.setCustomerId(customer.getId());
        contacts.setDescription((String)map.get("description"));
        contacts.setEmail((String)map.get("email"));
        contacts.setFullname((String)map.get("fullname"));
        contacts.setJob((String)map.get("job"));
        contacts.setMphone((String)map.get("mphone"));
        contacts.setOwner((String)map.get("owner"));
        contacts.setSource((String)map.get("source"));
        return contactsMapper.insertContacts(contacts);
    }

    @Override
    public List<Contacts> queryContactsByConditionForPage(Map<String, Object> map) {
        return contactsMapper.selectContactByConditionForPage(map);
    }

    @Override
    public int queryCountOfContactsByCondition(Map<String, Object> map) {
        return contactsMapper.selectCountOfContactsByCondition(map);
    }

    @Override
    public Contacts queryContactsById(String id) {
        return contactsMapper.selectContactsById(id);
    }

    @Override
    public int updateContacts(Contacts contacts) {
        contacts.setCustomerId(customerMapper.selectCustomerIdByName(contacts.getCustomerId()));
        return contactsMapper.updateContacts(contacts);
    }

    @Override
    public int saveDeleteContacts(String[] ids) {
        return contactsMapper.deleteContactsByIds(ids);
    }

    @Override
    public Contacts queryContactsByIdForDetail(String id) {
        return contactsMapper.selectContactsByIdForDetail(id);
    }

    @Override
    public List<ContactsRemark> queryContactsRemarkByContactsId(String id) {
        return contactsRemarkMapper.selectContactsRemarkByContactsId(id);
    }

    @Override
    public String[] queryActivityIdByContactsId(String id) {
        return contactsActivityRelationMapper.selectActivityIdByContactsId(id);
    }

    @Override
    public int saveCreateContactsRemark(ContactsRemark contactsRemark) {
        return contactsRemarkMapper.insertContactsRemark(contactsRemark);
    }

    @Override
    public int saveEditContactsRemark(ContactsRemark contactsRemark) {
        return contactsRemarkMapper.updateContactsRemark(contactsRemark);
    }

    @Override
    public int saveDeleteContactsRemarkById(String id) {
        return contactsRemarkMapper.deleteContactsRemarkById(id);
    }

    @Override
    public int saveCreateContactsActivityRelationByList(List<ContactsActivityRelation> list) {
        return contactsActivityRelationMapper.insertContactsActivityRelationByList(list);
    }

    @Override
    public int saveDeleteContactsActivityRelationByActivityIdContactsId(ContactsActivityRelation relation) {
        return contactsActivityRelationMapper.deleteContactsActivityRelationByActivityIdContactsId(relation);
    }

    @Override
    public List<Contacts> queryContactsByCustomerId(String customerId) {
        return contactsMapper.selectContactsByCustomerId(customerId);
    }

    @Override
    public int saveDeleteContacts(String id) {
        return contactsMapper.deleteContactsById(id);
    }
}

