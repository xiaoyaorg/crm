package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.workbench.domain.Customer;
import com.bjpowernode.crm.workbench.domain.CustomerRemark;

import java.util.List;
import java.util.Map;

public interface CustomerService {
    List<String> queryCustomerNameByName(String name);

    int saveCreateCustomer(Customer customer);

    List<Customer> queryCustomerByConditionForPage(Map<String,Object> map);

    int queryCountOfCustomerByCondition(Map<String,Object> map);

    Customer queryCustomerById(String id);

    int saveEditCustomer(Customer customer);

    int deleteCustomerByIds(String[] id);

    Customer queryCustomerByIdForDetail(String id);

    List<CustomerRemark> queryCustomerRemarkByCustomerId(String customerId);

    int saveCreateCustomerRemark(CustomerRemark customerRemark);

    int saveEditCustomerRemark(CustomerRemark customerRemark);

    int saveDeleteCustomerRemark(String id);
}
