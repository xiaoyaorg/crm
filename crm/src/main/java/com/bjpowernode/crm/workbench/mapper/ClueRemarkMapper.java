package com.bjpowernode.crm.workbench.mapper;

import com.bjpowernode.crm.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkMapper {
    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_remark
     *
     * @mbggenerated Tue Apr 11 17:11:42 CST 2023
     */
    int deleteByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_remark
     *
     * @mbggenerated Tue Apr 11 17:11:42 CST 2023
     */
    int insert(ClueRemark record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_remark
     *
     * @mbggenerated Tue Apr 11 17:11:42 CST 2023
     */
    int insertSelective(ClueRemark record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_remark
     *
     * @mbggenerated Tue Apr 11 17:11:42 CST 2023
     */
    ClueRemark selectByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_remark
     *
     * @mbggenerated Tue Apr 11 17:11:42 CST 2023
     */
    int updateByPrimaryKeySelective(ClueRemark record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_clue_remark
     *
     * @mbggenerated Tue Apr 11 17:11:42 CST 2023
     */
    int updateByPrimaryKey(ClueRemark record);

    List<ClueRemark> selectClueRemarkForDetailByClueId(String clueId);

    int insertClueRemark(ClueRemark clueRemark);

    int deleteClueRemarkById(String id);

    int updateClueRemark(ClueRemark clueRemark);

    List<ClueRemark> selectClueRemarkByClueId(String clueId);

    int deleteClueRemarkByClueId(String clueId);
}