package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.contants.Contants;
import com.bjpowernode.crm.commons.domin.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.domain.DicValue;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.DicValueService;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.workbench.domain.*;
import com.bjpowernode.crm.workbench.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

@Controller
public class TranController {
    @Autowired
    private UserService userService;
    @Autowired
    private DicValueService dicValueService;
    @Autowired
    private ActivityService activityService;
    @Autowired
    private ContactsService contactsService;
    @Autowired
    private CustomerService customerService;
    @Autowired
    private TranService tranService;
    @Autowired
    private TranRemarkService tranRemarkService;
    @Autowired
    private TranHistoryService tranHistoryService;

    @RequestMapping("/workbench/transaction/index.do")
    public String index(HttpServletRequest request){
        List<DicValue> stageList = dicValueService.queryDicValueByTypeCode("stage");
        List<DicValue> transactionTypeList = dicValueService.queryDicValueByTypeCode("transactionType");
        List<DicValue> sourceList = dicValueService.queryDicValueByTypeCode("source");
        request.setAttribute("stageList",stageList);
        request.setAttribute("transactionTypeList",transactionTypeList);
        request.setAttribute("sourceList",sourceList);
        return "workbench/transaction/index";
    }
    @RequestMapping("/workbench/transaction/createPage.do")
    public String createPage(HttpServletRequest request){
        List<User> userList = userService.queryAllUsers();
        List<DicValue> stageList = dicValueService.queryDicValueByTypeCode("stage");
        List<DicValue> transactionTypeList = dicValueService.queryDicValueByTypeCode("transactionType");
        List<DicValue> sourceList = dicValueService.queryDicValueByTypeCode("source");
        request.setAttribute("userList",userList);
        request.setAttribute("stageList",stageList);
        request.setAttribute("transactionTypeList",transactionTypeList);
        request.setAttribute("sourceList",sourceList);
        return "workbench/transaction/save";
    }
    @RequestMapping("/workbench/transaction/queryActivityByName.do")
    @ResponseBody
    public Object queryActivityByName(String activityName){
        List<Activity> activityList = activityService.queryActivityByName(activityName);
        return activityList;
    }
    @RequestMapping("/workbench/transaction/queryContactsByFullName.do")
    @ResponseBody
    public Object queryContactsByFullName(String fullname){
        List<Contacts> contactsList = contactsService.queryContactsByFullName(fullname);
        System.out.println(contactsList);
        return contactsList;
    }
    @RequestMapping("/workbench/transaction/getPossibilityByStage.do")
    @ResponseBody
    public Object getPossibilityByStage(String stageValue){
        ResourceBundle bundle = ResourceBundle.getBundle("possibility");
        String possibility = bundle.getString(stageValue);
        return possibility;
    }

    @RequestMapping("/workbench/transaction/queryCustomerNameByName.do")
    @ResponseBody
    public Object queryCustomerNameByName(String name){
        List<String> customerNameList = customerService.queryCustomerNameByName(name);
        return customerNameList;
    }

    @RequestMapping("/workbench/transaction/saveCreateTran.do")
    @ResponseBody
    public Object savaCreateTran(@RequestParam Map<String,Object> map, HttpSession session){
        map.put(Contants.SESSION_USER,session.getAttribute(Contants.SESSION_USER));
        System.out.println((String)map.get("contactsId"));
        ReturnObject returnObject = new ReturnObject();
        try{
            tranService.saveCreateTran(map);
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("因未知原因保存失败...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/transaction/queryTranByConditionForPage.do")
    @ResponseBody
    public Object queryTranByConditionForPage(String owner,String name,String customerId,String stage,String type,String source,
                                              String contactsId,int pageNo,int pageSize){
        Map<String,Object> map=new HashMap<>();
        map.put("owner",owner);
        map.put("name",name);
        map.put("customerId",customerId);
        map.put("stage",stage);
        map.put("type",type);
        map.put("source",source);
        map.put("contactsId",contactsId);
        map.put("beginNo",(pageNo-1)*pageSize);
        map.put("pageSize",pageSize);
        List<Tran> tranList = tranService.queryTranByConditionForPage(map);
        int totalRows = tranService.queryCountOfTranByCondition(map);
        Map<String,Object> resultMap=new HashMap<>();
        resultMap.put("tranList",tranList);
        resultMap.put("totalRows",totalRows);
        return resultMap;
    }

    @RequestMapping("/workbench/transaction/toEdit.do")
    public Object toEdit(HttpServletRequest request){
        String id = request.getParameter("id");
        Tran tran = tranService.queryTranByTranId(id);
        List<User> userList = userService.queryAllUsers();
        List<DicValue> stageList = dicValueService.queryDicValueByTypeCode("stage");
        List<DicValue> transactionTypeList = dicValueService.queryDicValueByTypeCode("transactionType");
        List<DicValue> sourceList = dicValueService.queryDicValueByTypeCode("source");
        String activityName = activityService.queryActivityNameById(tran.getActivityId());
        String fullName=contactsService.queryContactsFullNameById(tran.getContactsId());
        request.setAttribute("tran",tran);
        request.setAttribute("userList",userList);
        request.setAttribute("stageList",stageList);
        request.setAttribute("transactionTypeList",transactionTypeList);
        request.setAttribute("sourceList",sourceList);
        request.setAttribute("activityName",activityName);
        request.setAttribute("fullName",fullName);
        return "workbench/transaction/edit";
    }

    @RequestMapping("/workbench/transaction.saveEditTran.do")
    @ResponseBody
    public Object saveEditTran(Tran tran,HttpSession session){
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        tran.setEditBy(user.getId());
        tran.setEditTime(DateUtils.formateDateTime(new Date()));
        /*System.out.println(tran.getContactsId());
        System.out.println(tran.getActivityId());*/
        ReturnObject returnObject = new ReturnObject();
        try{
            int ret = tranService.saveEditTran(tran);
            if(ret==1){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统繁忙，稍后重试....");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，稍后重试....");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/transaction/saveDeleteTran.do")
    @ResponseBody
    public Object saveDeleteTran(String[] id){
        System.out.println(id);
        ReturnObject returnObject = new ReturnObject();
        try{
            int ret = tranService.saveDeleteTran(id);
            if(ret>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("因未知原因删除错误...");
            }
        }catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("因未知原因删除错误...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/transaction/queryTranRemarkHistoryById.do")
    public Object queryTranRemarkHistoryById(String id,HttpServletRequest request){
        Tran tran = tranService.queryTranByTranId(id);
        List<TranRemark> tranRemarkList = tranRemarkService.queryTranRemarkByTranId(id);
        List<TranHistory> tranHistoryList = tranHistoryService.queryTranHistoryByTranId(id);
        String activityName = activityService.queryActivityNameById(tran.getActivityId());
        String contactsName = contactsService.queryContactsFullNameById(tran.getContactsId());
        ResourceBundle bundle = ResourceBundle.getBundle("possibility");
        String possibility = bundle.getString(tran.getStage());
        /*System.out.println(id);
        System.out.println(tranHistoryList);*/

        List<DicValue> stageList = dicValueService.queryDicValueByTypeCode("stage");
        request.setAttribute("possibility",possibility);
        request.setAttribute("tran",tran);
        request.setAttribute("tranRemarkList",tranRemarkList);
        request.setAttribute("tranHistoryList",tranHistoryList);
        request.setAttribute("activityName",activityName);
        request.setAttribute("contactsName",contactsName);
        request.setAttribute("stageList",stageList);
        return "workbench/transaction/detail";
    }

    @RequestMapping("/workbench/transaction/saveCreateTranRemark.do")
    @ResponseBody
    public Object saveCreateTranRemark(TranRemark tranRemark,HttpSession session){
        tranRemark.setId(UUIDUtils.getUUID());
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        tranRemark.setCreateBy(user.getId());
        tranRemark.setCreateTime(DateUtils.formateDateTime(new Date()));
        tranRemark.setEditFlag(Contants.REMARK_EDIT_FLAG_NO_EDITED);
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = tranRemarkService.saveCreateTranRemark(tranRemark);
            if(ret>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(tranRemark);
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

    @RequestMapping("/workbench/transaction/updateTranRemark.do")
    @ResponseBody
    public Object updateTranRemark(TranRemark tranRemark,HttpSession session){
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        tranRemark.setEditFlag(Contants.REMARK_EDIT_FLAG_YES_EDITED);
        tranRemark.setEditBy(user.getId());
        tranRemark.setEditTime(DateUtils.formateDateTime(new Date()));
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = tranRemarkService.updateTranRemark(tranRemark);
            if(ret>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setRetData(tranRemark);
            }else{
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("因未知原因修改失败");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("因未知原因修改失败");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/transaction/deleteTranRemark.do")
    @ResponseBody
    public Object deleteTranRemark(String id){
        ReturnObject returnObject = new ReturnObject();
        try{
            int ret = tranRemarkService.deleteTranRemark(id);
            if(ret>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("因未知原因删除失败...");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("因未知原因删除失败...");
        }
        return returnObject;
    }
}
