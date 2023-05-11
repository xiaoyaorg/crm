package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.contants.Contants;
import com.bjpowernode.crm.commons.domin.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.domain.DicValue;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.mapper.UserMapper;
import com.bjpowernode.crm.settings.service.DicValueService;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.workbench.domain.*;
import com.bjpowernode.crm.workbench.service.ActivityService;
import com.bjpowernode.crm.workbench.service.ContactsService;
import com.bjpowernode.crm.workbench.service.TranService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

@Controller
public class ContactsController {
    @Autowired
    private UserService userService;
    @Autowired
    private DicValueService dicValueService;
    @Autowired
    private ContactsService contactsService;
    @Autowired
    private TranService tranService;
    @Autowired
    private ActivityService activityService;

    @RequestMapping("/workbench/contacts/index.do")
    public Object index(HttpServletRequest request){
        List<User> userList = userService.queryAllUsers();
        List<DicValue> sourceList = dicValueService.queryDicValueByTypeCode("source");
        List<DicValue> appellationList = dicValueService.queryDicValueByTypeCode("appellation");
        request.setAttribute("userList",userList);
        request.setAttribute("sourceList",sourceList);
        request.setAttribute("appellationList",appellationList);
        return "workbench/contacts/index";
    }

    @RequestMapping("/workbench/contacts/insertContacts.do")
    @ResponseBody
    public Object insertContacts(@RequestParam Map<String,Object> map, HttpSession session){
        map.put(Contants.SESSION_USER,session.getAttribute(Contants.SESSION_USER));
        ReturnObject returnObject = new ReturnObject();
        try{
            int ret = contactsService.saveCreateContacts(map);
            if(ret==1){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setMessage("因未知原因添加失败....");
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setMessage("因未知原因添加失败....");
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
        }
        return returnObject;
    }

    @RequestMapping("/workbench/contacts/queryContactsByConditionForPage.do")
    @ResponseBody
    public Object queryContactsByConditionForPage(String owner,String fullname,String customerId,String source,int pageNo,int pageSize){
        Map<String,Object> map=new HashMap<>();
        map.put("owner",owner);
        map.put("fullname",fullname);
        map.put("customerId",customerId);
        map.put("source",source);
        map.put("beginNo",(pageNo-1)*pageSize);
        map.put("pageSize",pageSize);
        System.out.println(map);
        List<Contacts> contactsList = contactsService.queryContactsByConditionForPage(map);
        int totalRows=contactsService.queryCountOfContactsByCondition(map);
        Map<String,Object> resultMap=new HashMap<>();
        resultMap.put("contactsList",contactsList);
        resultMap.put("totalRows",totalRows);
        return resultMap;
    }

    @RequestMapping("/workbench/contacts/queryContactsForEdit.do")
    @ResponseBody
    public Object queryContactsForEdit(String id){
        Contacts contacts = contactsService.queryContactsById(id);
        return contacts;
    }

    @RequestMapping("/workbench/contacts/saveEditContacts.do")
    @ResponseBody
    public Object saveEditContacts(Contacts contacts,HttpSession session){
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        contacts.setEditBy(user.getId());
        contacts.setEditTime(DateUtils.formateDateTime(new Date()));
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = contactsService.updateContacts(contacts);
            if (ret==1){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else{
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("因未知原因修改失败....");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("因未知原因修改失败....");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/contacts/saveDeleteContacts.do")
    @ResponseBody
    public Object saveDeleteContacts(String[] id){
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = contactsService.saveDeleteContacts(id);
            if(ret>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else{
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("因未知原因删除错误...");
            }
        }catch (Exception e){
            e.printStackTrace();
        }
        return returnObject;
    }

    @RequestMapping("/workbench/contacts/DetailContacts.do")
    public Object DetailContacts(String id,HttpServletRequest request){
        Contacts contacts = contactsService.queryContactsByIdForDetail(id);
        List<ContactsRemark> contactsRemarkList = contactsService.queryContactsRemarkByContactsId(id);
        List<Tran> tranList = tranService.queryTranByContactsId(id);
        for (Tran tran : tranList) {
            ResourceBundle bundle = ResourceBundle.getBundle("possibility");
            String possibility = bundle.getString(tran.getStage());
            tran.setPossibility(possibility);
        }
        /*String[] ids = contactsService.queryActivityIdByContactsId(id);
        List<Activity> activityList = activityService.queryActivityForDetailByIds(ids);*/
        List<Activity> activityList = activityService.queryActivityByContactsId(id);
        request.setAttribute("contacts",contacts);
        request.setAttribute("contactsRemarkList",contactsRemarkList);
        request.setAttribute("tranList",tranList);
        request.setAttribute("activityList",activityList);
        return "workbench/contacts/detail";
    }

    @RequestMapping("/workbench/contacts/saveCreateContactsRemark.do")
    @ResponseBody
    public Object saveCreateContactsRemark(ContactsRemark contactsRemark,HttpSession session){
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        contactsRemark.setId(UUIDUtils.getUUID());
        contactsRemark.setCreateBy(user.getId());
        contactsRemark.setCreateTime(DateUtils.formateDateTime(new Date()));
        contactsRemark.setEditFlag(Contants.REMARK_EDIT_FLAG_NO_EDITED);
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = contactsService.saveCreateContactsRemark(contactsRemark);
            if (ret == 1) {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(contactsRemark);
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

    @RequestMapping("/workbench/contacts/saveEditContactsRemark.do")
    @ResponseBody
    public Object saveEditContactsRemark(ContactsRemark contactsRemark,HttpSession session){
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        contactsRemark.setEditFlag(Contants.REMARK_EDIT_FLAG_YES_EDITED);
        contactsRemark.setEditBy(user.getId());
        contactsRemark.setEditTime(DateUtils.formateDateTime(new Date()));
        ReturnObject returnObject=new ReturnObject();
        try {
            //调用service层方法，保存创建的市场活动备注
            int ret = contactsService.saveEditContactsRemark(contactsRemark);

            if(ret>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(contactsRemark);
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

    @RequestMapping("/workbench/contacts/saveDeleteContactsRemarkById.do")
    @ResponseBody
    public Object saveDeleteContactsRemarkById(String id){
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = contactsService.saveDeleteContactsRemarkById(id);
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

    @RequestMapping("/workbench/contacts/saveDeleteTran.do")
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

    @RequestMapping("/workbench/contacts/queryActivityForDetailByNameContactsId.do")
    @ResponseBody
    public Object queryActivityForDetailByNameContactsId(String activityName,String contactsId){
        Map<String,Object> map=new HashMap<>();
        map.put("activityName",activityName);
        map.put("contactsId",contactsId);
        List<Activity> activityList = activityService.queryActivityForDetailByNameContactsId(map);
        return activityList;
    }

    @RequestMapping("/workbench/contacts/saveBound.do")
    @ResponseBody
    public Object saveBound(String[] activityId,String contactsId){
        System.out.println(contactsId);
        ContactsActivityRelation contactsActivityRelation=null;
        List<ContactsActivityRelation> relationList=new ArrayList<>();
        for (String aid: activityId) {
            contactsActivityRelation = new ContactsActivityRelation();
            contactsActivityRelation.setActivityId(aid);
            contactsActivityRelation.setContactsId(contactsId);
            contactsActivityRelation.setId(UUIDUtils.getUUID());
            relationList.add(contactsActivityRelation);
        }
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = contactsService.saveCreateContactsActivityRelationByList(relationList);
            if(ret>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                List<Activity> activityList = activityService.queryActivityForDetailByIds(activityId);
                returnObject.setRetData(activityList);
            }else{
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("因未知原因，关联失败....");
            }

        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("因未知原因，关联失败....");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/contacts/deleteBound.do")
    @ResponseBody
    public Object deleteBound(ContactsActivityRelation relation){
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = contactsService.saveDeleteContactsActivityRelationByActivityIdContactsId(relation);
            if(ret>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("因未知原因解除关联失败...");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("因未知原因解除关联失败...");
        }
        return returnObject;
    }
}
