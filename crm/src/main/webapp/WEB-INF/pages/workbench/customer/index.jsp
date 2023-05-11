<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath=request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getContextPath()+"/";
%>

<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<link rel="stylesheet" type="text/css" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>
<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

<script type="text/javascript">

	$(function(){
		
		//定制字段
		$("#definedColumns > li").click(function(e) {
			//防止下拉菜单消失
	        e.stopPropagation();
	    });

		queryCustomerByConditionForPage(1,10);

		$("#createCustomerBtn").click(function () {
			$("#createCustomerModal").modal("show");
		});

		$("#createCustomerBtn").click(function () {
			$("#createCustomerModal").modal("show");
		});

		$(".myDate").datetimepicker({
			language:'zh-CN', //语言
			format:'yyyy-mm-dd',//日期的格式
			minView:'month', //可以选择的最小视图
			initialDate:new Date(),//初始化显示的日期
			autoClose:true,//设置选择完日期或者时间之后，
			todayBtn:true,
			clearBtn:true
		})

		$("#checkAll").click(function () {
			$("#tBody input[type='checkbox']").prop("checked",this.checked)
		})

		$("#tBody").on("click","input[type='checkbox']",function () {
			if($("#tBody input[type='checkbox']").size()==$("#tBody input[type='checkbox']:checked").size()){
				$("#checkAll").prop("checked",true);
			}else{
				$("#checkAll").prop("checked",false);
			}
		})

        $("#queryCustomerBtn").click(function () {
            queryCustomerByConditionForPage(1,$("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'));
        });

		$("#saveCreateCustomerBtn").click(function (){
			let owner =$("#create-customerOwner").val();
			let name =$.trim($("#create-customerName").val());
			let website=$.trim($("#create-website").val());
			let phone=$("#create-phone").val();
			let description=$("#create-description").val();
			let contactSummary=$("#create-contactSummary").val();
			let nextContactTime=$("#create-nextContactTime").val();
			let address=$("#create-address1").val();
			if(name==""){
				alert("名称不能为空");
				return;
			}
            if(owner==""){
                alert("所有者不能为空");
                return;
            }
            let reg2=/^0\d{2}-\d{8}$/;
            if(!reg2.test(phone)){
                alert("座机号不合法,12位座机号");
                return;
            }
            $.ajax({
               url:"workbench/customer/saveCreateCustomer.do",
                data:{
                   owner:owner,
                   name:name,
                   website:website,
                   phone:phone,
                   description:description,
                   contactSummary:contactSummary,
                   nextContactTime:nextContactTime,
                   address:address
                },
                type:"post",
                dataType:"json",
                success:function (data) {
                    if(data.code=="1"){
                        $("#createCustomerModal").modal("hide");
						queryCustomerByConditionForPage(1,$("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'));
                    }else {
						alert(data.message);
					}
                }
            });
		});

		$("#editCustomerBtn").click(function () {
			let checkedIds=$("#tBody input[type='checkbox']:checked");
			if(checkedIds.size()==0){
				alert("请选择要修改的客户");
				return;
			}
			if(checkedIds.size()>1){
				alert("只能修改一个客户");
				return;
			}
			let id=checkedIds.val();
			$.ajax({
				url:"workbench/customer/queryCustomerById.do",
				data:{
					id:id
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					$("#edit-id").val(data.id);
					$("#edit-customerOwner").val(data.owner);
					$("#edit-customerName").val(data.name);
					$("#edit-website").val(data.website);
					$("#edit-phone").val(data.phone);
					$("#edit-description").val(data.description);
					$("#edit-contactSummary1").val(data.contactSummary);
					$("#edit-nextContactTime2").val(data.nextContactTime);
					$("#edit-customerAddress").val(data.address);
					$("#editCustomerModal").modal("show");
				}
			});
		});

        $("#saveEditCustomerBtn").click(function () {
            let id=$("#edit-id").val();
            let owner=$("#edit-customerOwner").val();
            let name=$("#edit-customerName").val();
            let website=$("#edit-website").val();
            let phone=$("#edit-phone").val();
            let description=$("#edit-description").val();
            let contactSummary=$("#edit-contactSummary1").val();
            let nextContactTime=$("#edit-nextContactTime2").val();
            let address=$("#edit-customerAddress").val();
            if(name==""){
                alert("名称不能为空");
                return;
            }
            if(owner==""){
                alert("所有者不能为空");
                return;
            }
            let reg2=/^0\d{2}-\d{8}$/;
            if(!reg2.test(phone)){
                alert("座机号不合法,12位座机号");
                return;
            }
            $.ajax({
               url:"workbench/customer/saveEditCustomer.do",
               data:{
                   id:id,
                   owner:owner,
                   name:name,
                   website:website,
                   phone:phone,
                   description:description,
                   contactSummary:contactSummary,
                   nextContactTime:nextContactTime,
                   address:address
               },
               type:"post",
               dataType:"json",
               success:function (data) {
                   if(data.code=="1"){
                       $("#editCustomerModal").modal("hide");
                       queryCustomerByConditionForPage($("#demo_pag1").bs_pagination('getOption', 'currentPage'),$("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'));
                   }else{
                       alert(data.message);
                   }
               }
            });
        });

		$("#deleteCustomerBtn").click(function () {
			let checkedIds=$("#tBody input[type='checkbox']:checked");
			if(checkedIds.size()==0){
				alert("请选择要删除的客户");
				return;
			}
			if(window.confirm("确定删除吗？")){
				let ids="";
				$.each(checkedIds,function () {
					ids+="id="+this.value+"&";
				});
				ids=ids.substr(0,ids.length-1);
				$.ajax({
					url:"workbench/customer/deleteCustomerByIds.do",
					data:ids,
					type:"post",
					dataType:"json",
					success:function (data) {
						if(data.code=="1"){
							queryCustomerByConditionForPage(1,$("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'));
						}
						else {
							alert(data.message);
						}
					}
				});
			}
		});


	});

	function queryCustomerByConditionForPage(pageNo,pageSize){
		let name=$("#queryCustomerName").val();
		let owner=$("#queryCustomerOwner").val();
		let phone=$("#queryCustomerPhone").val();
		let website=$("#queryCustomerWebsite").val();
		$.ajax({
			url:"workbench/customer/queryCustomerByConditionForPage.do",
			data:{
				name:name,
				owner:owner,
				phone:phone,
				website:website,
				pageNo:pageNo,
				pageSize:pageSize
			},
			type:"post",
			dataType:"json",
			success:function (data) {
				let htmlStr="";
				$.each(data.customerList,function (index, obj) {
					htmlStr+="<tr>"
					htmlStr+="<td><input type=\"checkbox\" value='"+obj.id+"' /></td>"
					htmlStr+="<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/customer/queryCustomerByIdForDetail.do?id="+obj.id+"';\">"+obj.name+"</a></td>"
					htmlStr+="<td>"+obj.owner+"</td>"
					htmlStr+="<td>"+obj.phone+"</td>"
					htmlStr+="<td>"+obj.website+"</td>"
					htmlStr+="</tr>"
				});
				$("#tBody").html(htmlStr);
				$("#checkAll").prop("checked",false);
				//计算总页数
				let totalPages=1;
				if(data.totalRows%pageSize==0){
					totalPages=data.totalRows/pageSize;
				}else{
					totalPages=parseInt(data.totalRows/pageSize)+1;
				}
				$("#demo_pag1").bs_pagination({
					currentPage:pageNo,//当前页号,相当于pageNo

					rowsPerPage:pageSize,//每页显示条数,相当于pageSize
					totalRows:data.totalRows,//总条数
					totalPages: totalPages,  //总页数,必填参数.

					visiblePageLinks:5,//最多可以显示的卡片数

					showGoToPage:true,//是否显示"跳转到"部分,默认true--显示
					showRowsPerPage:true,//是否显示"每页显示条数"部分。默认true--显示
					showRowsInfo:true,//是否显示记录的信息，默认true--显示

					//用户每次切换页号，都自动触发本函数;
					//每次返回切换页号之后的pageNo和pageSize
					onChangePage: function(event,pageObj) {
						queryCustomerByConditionForPage(pageObj.currentPage,pageObj.rowsPerPage);
					}
				});
			}
		});
	}
</script>
</head>
<body>

	<!-- 创建客户的模态窗口 -->
	<div class="modal fade" id="createCustomerModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建客户</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-customerOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-customerOwner">
								  <c:forEach items="${userList}" var="user">
									  <option value="${user.id}">${user.name}</option>
								  </c:forEach>
								</select>
							</div>
							<label for="create-customerName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-customerName">
							</div>
						</div>
						
						<div class="form-group">
                            <label for="create-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-website">
                            </div>
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
						</div>
						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                        <div style="position: relative;top: 15px;">
                            <div class="form-group">
                                <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control myDate" id="create-nextContactTime" readonly>
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="create-address1" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address1"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" id="saveCreateCustomerBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改客户的模态窗口 -->
	<div class="modal fade" id="editCustomerModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改客户</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-customerOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-customerOwner">
								  <c:forEach items="${userList}" var="user">
									  <option value="${user.id}">${user.name}</option>
								  </c:forEach>
								</select>
							</div>
							<label for="edit-customerName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-customerName" value="动力节点">
							</div>
						</div>
						
						<div class="form-group">
                            <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-website" value="http://www.bjpowernode.com">
                            </div>
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone" value="010-84846003">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                        <div style="position: relative;top: 15px;">
                            <div class="form-group">
                                <label for="edit-contactSummary1" class="col-sm-2 control-label">联系纪要</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="3" id="edit-contactSummary1"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="edit-nextContactTime2" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control myDate" id="edit-nextContactTime2" readonly>
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-customerAddress" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-customerAddress"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" id="saveEditCustomerBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>客户列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="queryCustomerName">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="queryCustomerOwner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司座机</div>
				      <input class="form-control" type="text" id="queryCustomerPhone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司网站</div>
				      <input class="form-control" type="text" id="queryCustomerWebsite">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="queryCustomerBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createCustomerBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editCustomerBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteCustomerBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAll" /></td>
							<td>名称</td>
							<td>所有者</td>
							<td>公司座机</td>
							<td>公司网站</td>
						</tr>
					</thead>
					<tbody id="tBody">
					</tbody>
				</table>
			</div>
			
			<div id="demo_pag1"></div>
			
		</div>
		
	</div>
</body>
</html>