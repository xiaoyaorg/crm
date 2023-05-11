package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.workbench.domain.TranRemark;

import java.util.List;

public interface TranRemarkService {
    List<TranRemark> queryTranRemarkByTranId(String id);

    int saveCreateTranRemark(TranRemark tranRemark);

    int updateTranRemark(TranRemark tranRemark);

    int deleteTranRemark(String id);
}
