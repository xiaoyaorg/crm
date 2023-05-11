package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.commons.contants.Contants;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.workbench.domain.Customer;
import com.bjpowernode.crm.workbench.domain.FunnelVO;
import com.bjpowernode.crm.workbench.domain.Tran;
import com.bjpowernode.crm.workbench.domain.TranHistory;
import com.bjpowernode.crm.workbench.mapper.*;
import com.bjpowernode.crm.workbench.service.TranService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Map;

@Service("tranService")
public class TranServiceImpl implements TranService {
    @Autowired
    private CustomerMapper customerMapper;
    @Autowired
    private TranMapper tranMapper;
    @Autowired
    private TranHistoryMapper tranHistoryMapper;
    @Override
    public void saveCreateTran(Map<String, Object> map) {
        String customerName=(String) map.get("customerName");
        Customer customer = customerMapper.selectCustomerByCustomerName(customerName);
        User user = (User) map.get(Contants.SESSION_USER);
        if(customer==null){
            customer=new Customer();
            customer.setCreateBy(user.getId());
            customer.setId(UUIDUtils.getUUID());
            customer.setCreateTime(DateUtils.formateDateTime(new Date()));
            customer.setName(customerName);
            customer.setOwner(user.getId());
            customerMapper.insertCustomer(customer);
        }
        Tran tran = new Tran();
        tran.setCreateBy(user.getId());
        tran.setId(UUIDUtils.getUUID());
        tran.setOwner((String)map.get("owner"));
        tran.setName((String)map.get("name"));
        tran.setCreateTime(DateUtils.formateDateTime(new Date()));
        tran.setCustomerId(customer.getId());
        tran.setStage((String)map.get("stage"));
        tran.setContactsId((String)map.get("contactsId"));
        tran.setExpectedDate((String)map.get("expectedDate"));
        tran.setContactSummary((String)map.get("contactSummary"));
        tran.setMoney((String)map.get("money"));
        tran.setDescription((String)map.get("description"));
        tran.setSource((String)map.get("source"));
        tran.setActivityId((String)map.get("activityId"));
        tran.setNextContactTime((String)map.get("nextContactTime"));
        tran.setType((String)map.get("type"));
        tranMapper.insertTran(tran);

        TranHistory tranHistory = new TranHistory();
        tranHistory.setCreateBy(user.getId());
        tranHistory.setTranId(tran.getId());
        tranHistory.setCreateTime(DateUtils.formateDateTime(new Date()));
        tranHistory.setMoney(tran.getMoney());
        tranHistory.setStage(tran.getStage());
        tranHistory.setExpectedDate(tran.getExpectedDate());
        tranHistory.setId(UUIDUtils.getUUID());
        tranHistoryMapper.insertTranHistory(tranHistory);
    }

    @Override
    public List<Tran> queryTranByConditionForPage(Map<String, Object> map) {
        return tranMapper.selectTranByConditionForPage(map);
    }

    @Override
    public int queryCountOfTranByCondition(Map<String, Object> map) {
        return tranMapper.selectCountOfTranByCondition(map);
    }

    @Override
    public Tran queryTranByTranId(String id) {
        return tranMapper.selectTranByTranId(id);
    }

    @Override
    public int saveEditTran(Tran tran) {
        tran.setCustomerId(customerMapper.selectCustomerIdByName(tran.getCustomerId()));
        TranHistory tranHistory = new TranHistory();
        tranHistory.setCreateBy(tran.getEditBy());
        tranHistory.setTranId(tran.getId());
        tranHistory.setCreateTime(DateUtils.formateDateTime(new Date()));
        tranHistory.setMoney(tran.getMoney());
        tranHistory.setStage(tran.getStage());
        tranHistory.setExpectedDate(tran.getExpectedDate());
        tranHistory.setId(UUIDUtils.getUUID());
        tranHistoryMapper.insertTranHistory(tranHistory);
        return tranMapper.updateTran(tran);
    }

    @Override
    public int saveDeleteTran(String[] ids) {
        return tranMapper.deleteTran(ids);
    }

    @Override
    public List<FunnelVO> queryCountOfTranGroupByStage() {
        return tranMapper.selectCountOfTranGroupByStage();
    }

    @Override
    public List<Tran> queryTranByContactsId(String contactsId) {
        return tranMapper.selectTranByContactsId(contactsId);
    }

    @Override
    public int saveDeleteTranById(String id) {
        return tranMapper.deleteTranById(id);
    }

    @Override
    public List<Tran> queryTranByCustomerId(String customerId) {
        return tranMapper.selectTranByCustomerId(customerId);
    }
}
