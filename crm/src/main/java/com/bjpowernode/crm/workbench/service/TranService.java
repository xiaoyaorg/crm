package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.workbench.domain.FunnelVO;
import com.bjpowernode.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface TranService {
    void saveCreateTran(Map<String,Object> map);

    List<Tran> queryTranByConditionForPage(Map<String,Object> map);

    int queryCountOfTranByCondition(Map<String,Object> map);

    Tran queryTranByTranId(String id);

    int saveEditTran(Tran tran);

    int saveDeleteTran(String[] ids);

    List<FunnelVO> queryCountOfTranGroupByStage();

    List<Tran> queryTranByContactsId(String contactsId);

    int saveDeleteTranById(String id);

    List<Tran> queryTranByCustomerId(String customerId);
}
