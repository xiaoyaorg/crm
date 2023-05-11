package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.contants.Contants;
import com.bjpowernode.crm.commons.domin.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.domain.DicValue;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.DicValueService;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.workbench.domain.Contacts;
import com.bjpowernode.crm.workbench.domain.Customer;
import com.bjpowernode.crm.workbench.domain.CustomerRemark;
import com.bjpowernode.crm.workbench.domain.Tran;
import com.bjpowernode.crm.workbench.service.ContactsService;
import com.bjpowernode.crm.workbench.service.CustomerService;
import com.bjpowernode.crm.workbench.service.TranService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

@Controller
public class CustomerController {
    @Autowired
    private UserService userService;
    @Autowired
    private CustomerService customerService;
    @Autowired
    private TranService tranService;
    @Autowired
    private ContactsService contactsService;
    @Autowired
    private DicValueService dicValueService;

    @RequestMapping("/workbench/customer/index.do")
    public String index(HttpServletRequest request){
        List<User> userList = userService.queryAllUsers();
        request.setAttribute("userList",userList);
        return "workbench/customer/index";
    }

    @RequestMapping("/workbench/customer/saveCreateCustomer.do")
    @ResponseBody
    public Object saveCreateCustomer(Customer customer, HttpSession session){
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        customer.setCreateBy(user.getId());
        customer.setCreateTime(DateUtils.formateDateTime(new Date()));
        customer.setId(UUIDUtils.getUUID());
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = customerService.saveCreateCustomer(customer);
            if(ret==1){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("因未知原因添加失败....");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("因未知原因添加失败....");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/customer/queryCustomerByConditionForPage.do")
    @ResponseBody
    public Object queryCustomerByConditionForPage(String name,String owner,String phone,String website,int pageNo,int pageSize){
        Map<String,Object> map=new HashMap<>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("phone",phone);
        map.put("website",website);
        map.put("beginNo",(pageNo-1)*pageSize);
        map.put("pageSize",pageSize);
        List<Customer> customerList = customerService.queryCustomerByConditionForPage(map);
        int totalRows = customerService.queryCountOfCustomerByCondition(map);
        Map<String,Object> resultMap=new HashMap<>();
        resultMap.put("customerList",customerList);
        resultMap.put("totalRows",totalRows);
        return resultMap;
    }

    @RequestMapping("/workbench/customer/queryCustomerById.do")
    @ResponseBody
    public Object queryCustomerById(String id){
        Customer customer = customerService.queryCustomerById(id);
        return customer;
    }

    @RequestMapping("/workbench/customer/saveEditCustomer.do")
    @ResponseBody
    public Object saveEditCustomer(Customer customer,HttpSession session){
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        customer.setEditBy(user.getId());
        customer.setEditTime(DateUtils.formateDateTime(new Date()));
        ReturnObject returnObject = new ReturnObject();
        try{
            int ret = customerService.saveEditCustomer(customer);
            if(ret==1){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else{
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("因未知原因保存失败...");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("因未知原因保存失败...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/customer/deleteCustomerByIds.do")
    @ResponseBody
    public Object deleteCustomerByIds(String[] id){
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = customerService.deleteCustomerByIds(id);
            if(ret>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("因未知原因删除客户失败.....");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("因未知原因删除客户失败.....");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/customer/queryCustomerByIdForDetail.do")
    public Object queryCustomerByIdForDetail(String id,HttpServletRequest request){
        Customer customer = customerService.queryCustomerByIdForDetail(id);
        List<CustomerRemark> customerRemarkList = customerService.queryCustomerRemarkByCustomerId(id);
        List<Tran> tranList = tranService.queryTranByCustomerId(id);
        for (Tran tran : tranList) {
            ResourceBundle bundle = ResourceBundle.getBundle("possibility");
            String possibility = bundle.getString(tran.getStage());
            tran.setPossibility(possibility);
        }
        List<Contacts> contactsList = contactsService.queryContactsByCustomerId(id);
        List<User> userList = userService.queryAllUsers();
        List<DicValue> sourceList = dicValueService.queryDicValueByTypeCode("source");
        List<DicValue> appellationList = dicValueService.queryDicValueByTypeCode("appellation");
        request.setAttribute("userList",userList);
        request.setAttribute("sourceList",sourceList);
        request.setAttribute("appellationList",appellationList);
        request.setAttribute("customer",customer);
        request.setAttribute("customerRemarkList",customerRemarkList);
        request.setAttribute("tranList",tranList);
        request.setAttribute("contactsList",contactsList);
        return "workbench/customer/detail";
    }

    @RequestMapping("/workbench/customer/saveCreateCustomerRemark.do")
    @ResponseBody
    public Object saveCreateCustomerRemark(CustomerRemark customerRemark,HttpSession session){
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        customerRemark.setCreateBy(user.getId());
        customerRemark.setCreateTime(DateUtils.formateDateTime(new Date()));
        customerRemark.setId(UUIDUtils.getUUID());
        customerRemark.setEditFlag(Contants.REMARK_EDIT_FLAG_NO_EDITED);
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = customerService.saveCreateCustomerRemark(customerRemark);
            if (ret==1){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(customerRemark);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("因未知原因保存备注失败...");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("因未知原因保存备注失败...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/customer/saveEditCustomerRemark.do")
    @ResponseBody
    public Object saveEditCustomerRemark(CustomerRemark customerRemark,HttpSession session){
        User user= (User) session.getAttribute(Contants.SESSION_USER);
        customerRemark.setEditFlag(Contants.REMARK_EDIT_FLAG_YES_EDITED);
        customerRemark.setEditBy(user.getId());
        customerRemark.setEditTime(DateUtils.formateDateTime(new Date()));
        ReturnObject returnObject=new ReturnObject();
        try {
            //调用service层方法，保存创建的市场活动备注
            int ret = customerService.saveEditCustomerRemark(customerRemark);

            if(ret>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(customerRemark);
            }else{
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统忙，请稍后重试....");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后重试....");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/customer/saveDeleteCustomerRemark.do")
    @ResponseBody
    public Object saveDeleteCustomerRemark(String id){
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = customerService.saveDeleteCustomerRemark(id);
            if(ret>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("因未知原因删除备注失败....");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("因未知原因删除备注失败....");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/customer/saveDeleteTran.do")
    @ResponseBody
    public Object saveDeleteTran(String id){
        ReturnObject returnObject = new ReturnObject();
        try{
            int ret = tranService.saveDeleteTranById(id);
            if(ret==1){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else{
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("因未知原因删除失败....");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("因未知原因删除失败....");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/customer/saveDeleteContacts.do")
    @ResponseBody
    public Object saveDeleteContacts(String id){
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = contactsService.saveDeleteContacts(id);
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
        }catch (Exception e){
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("因未知原因删除失败....");
        }
        return returnObject;
    }
}
