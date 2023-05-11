package com.bjpowernode.crm.settings.mapper;

import com.bjpowernode.crm.settings.domain.User;
import org.apache.ibatis.annotations.Param;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;
import java.util.Map;

public interface UserMapper {
    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_user
     *
     * @mbggenerated Tue Mar 28 18:46:14 CST 2023
     */
    int deleteByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_user
     *
     * @mbggenerated Tue Mar 28 18:46:14 CST 2023
     */
    int insert(User record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_user
     *
     * @mbggenerated Tue Mar 28 18:46:14 CST 2023
     */
    int insertSelective(User record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_user
     *
     * @mbggenerated Tue Mar 28 18:46:14 CST 2023
     */
    User selectByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_user
     *
     * @mbggenerated Tue Mar 28 18:46:14 CST 2023
     */
    int updateByPrimaryKeySelective(User record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_user
     *
     * @mbggenerated Tue Mar 28 18:46:14 CST 2023
     */
    int updateByPrimaryKey(User record);

    User selectUserByLoginActAndPwd(Map<String,Object> map);

    List<User> selectAllUsers();

    int updatePassword(@Param("password") String password,@Param("newPassword") String newPassword,@Param("id") String id);
}