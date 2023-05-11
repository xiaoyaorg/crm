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
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	let cancelAndSaveBtnDefault = true;
	
	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});

		$("#remarkDivList").on("mouseover",".remarkDiv",function () {
			$(this).children("div").children("div").show();
		});

		$("#remarkDivList").on("mouseout",".remarkDiv",function () {
			$(this).children("div").children("div").hide();
		});

		$("#remarkDivList").on("mouseover",".myHref",function () {
			$(this).children("span").css("color","red");
		});

		$("#remarkDivList").on("mouseout",".myHref",function () {
			$(this).children("span").css("color","#E6E6E6");
		});

		$("#saveCreateCustomerRemarkBtn").click(function () {
			let noteContent=$.trim($("#remark").val());
			let customerId='${customer.id}';
			if (noteContent==""){
				alert("备注不能为空");
				return;
			}
			$.ajax({
				url:"workbench/customer/saveCreateCustomerRemark.do",
				data:{
					noteContent:noteContent,
					customerId:customerId
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					if(data.code=="1"){
						//清空输入框
						$("#remark").val("");
						let htmlStr="";
						htmlStr+="<div id=\"div_"+data.retData.id+"\" class=\"remarkDiv\" style=\"height: 60px;\">";
						htmlStr+="<img title=\"${sessionScope.sessionUser.name}\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">";
						htmlStr+="<div style=\"position: relative; top: -40px; left: 40px;\" >";
						htmlStr+="<h5>"+ data.retData.noteContent+"</h5>";
						htmlStr+="<font color=\"gray\">客户</font> <font color=\"gray\">-</font> <b>${customer.name}</b> <small style=\"color: gray;\"> "+data.retData.createTime+" 由${sessionScope.sessionUser.name}创建</small>";
						htmlStr+="<div style=\"position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;\">";
						htmlStr+="<a class=\"myHref\" name=\"editC\" remarkId=\""+data.retData.id+"\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-edit\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
						htmlStr+="&nbsp;&nbsp;&nbsp;&nbsp;";
						htmlStr+="<a class=\"myHref\" name=\"deleteC\" remarkId=\""+data.retData.id+"\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-remove\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
						htmlStr+="</div>";
						htmlStr+="</div>";
						htmlStr+="</div>";
						$("#remarkDiv").before(htmlStr);
					}else {
						alert(data.message);
					}
				}
			});
		});

		$("#remarkDivList").on("click","a[name='editC']",function () {
			//获取备注的id和noteContent
			let id=$(this).attr("remarkId");
			let noteContent=$("#div_"+id+" h5").text();
			//把备注的id和noteContent写到修改备注的模态窗口中
			$("#edit-id").val(id);
			$("#edit-noteContent").val(noteContent);
			//弹出修改市场活动备注的模态窗口
			$("#editRemarkModal").modal("show");
		});

		$("#updateRemarkBtn").click(function () {
			let noteContent=$.trim($("#edit-noteContent").val());
			let id=$("#edit-id").val();
			if(noteContent==""){
				alert("修改信息不能为空");
				return;
			}
			$.ajax({
				url:"workbench/customer/saveEditCustomerRemark.do",
				data:{
					noteContent:noteContent,
					id:id
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					if(data.code=="1"){
						$("#div_"+data.retData.id+" h5").text(data.retData.noteContent);
						$("#div_"+data.retData.id+" small").text(" "+data.retData.editTime+" 由${sessionScope.sessionUser.name}修改");
						//关闭模态窗口
						$("#editRemarkModal").modal("hide");
					}else{
						alert(data.message);
						//模态窗口不关闭
						$("#editRemarkModal").modal("show");
					}
				}
			});
		});

		$("#remarkDivList").on("click","a[name='deleteC']",function () {
			let id=$(this).attr("remarkId");
			$.ajax({
				url:"workbench/customer/saveDeleteCustomerRemark.do",
				data:{
					id:id
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					if(data.code=="1"){
						$("#div_"+id).remove();
					}else{
						alert(data.message);
					}
				}
			})
		})

		$("#tBody").on("click","a.x",function () {
			let id=$(this).attr("tranId");
			if(window.confirm("确定删除吗?")){
				$.ajax({
					url:"workbench/customer/saveDeleteTran.do",
					data:{
						id:id
					},
					type:"post",
					dataType:"json",
					success:function (data) {
						if(data.code=="1"){
							$("#tr_"+id).remove();
						}else {
							alert(data.message);
						}
					}
				});
			}

		})

		$("#deleteContactsBtn1").click(function () {
			$("#removeContactsModal").modal("show");
			$("#contactsId").val($(this).attr("contactsId"));
		});

		$("#deleteContactsBtn").click(function () {
			let id=$("#contactsId").val();
			$.ajax({
				url:"workbench/customer/saveDeleteContacts.do",
				data:{
					id:id
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					if(data.code=="1"){
						$("#tr_"+id).remove();
						$("#removeContactsModal").modal("hide");
					}else {
						alert(data.message);
					}
				}
			});
		});
	});
	
</script>

</head>
<body>
	<!-- 创建联系人的模态窗口 -->
	<div class="modal fade" id="createContactsModal" role="dialog">
	<div class="modal-dialog" role="document" style="width: 85%;">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal">
					<span aria-hidden="true">×</span>
				</button>
				<h4 class="modal-title" id="myModalLabelX">创建联系人</h4>
			</div>
			<div class="modal-body">
				<form class="form-horizontal" role="form" id="createContactForm">

					<div class="form-group">
						<label for="contacts-create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
						<div class="col-sm-10" style="width: 300px;">
							<select class="form-control" id="contacts-create-owner">
								<c:forEach items="${userList}" var="user">
									<option value="${user.id}">${user.name}</option>
								</c:forEach>
							</select>
						</div>
						<label for="contacts-create-source" class="col-sm-2 control-label">来源</label>
						<div class="col-sm-10" style="width: 300px;">
							<select class="form-control" id="contacts-create-source">
								<option></option>
								<c:forEach items="${sourceList}" var="source">
									<option value="${source.id}">${source.value}</option>
								</c:forEach>
							</select>
						</div>
					</div>

					<div class="form-group">
						<label for="contacts-create-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="contacts-create-fullname">
						</div>
						<label for="contacts-create-appellation" class="col-sm-2 control-label">称呼</label>
						<div class="col-sm-10" style="width: 300px;">
							<select class="form-control" id="contacts-create-appellation">
								<option></option>
								<c:forEach items="${appellationList}" var="appellation">
									<option value="${appellation.id}">${appellation.value}</option>
								</c:forEach>
							</select>
						</div>

					</div>

					<div class="form-group">
						<label for="contacts-create-job" class="col-sm-2 control-label">职位</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="contacts-create-job">
						</div>
						<label for="contacts-create-mphone" class="col-sm-2 control-label">手机</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="contacts-create-mphone">
						</div>
					</div>

					<div class="form-group" style="position: relative;">
						<label for="contacts-create-email" class="col-sm-2 control-label">邮箱</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="contacts-create-email">
						</div>
						<%--<label for="contacts-create-birth" class="col-sm-2 control-label">生日</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="contacts-create-birth">
                        </div>--%>
					</div>

					<div class="form-group" style="position: relative;">
						<label for="create-customerName" class="col-sm-2 control-label">客户名称</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="create-customerName" placeholder="支持自动补全，输入客户不存在则新建">
						</div>
					</div>

					<div class="form-group" style="position: relative;">
						<label for="contacts-create-description" class="col-sm-2 control-label">描述</label>
						<div class="col-sm-10" style="width: 81%;">
							<textarea class="form-control" rows="3" id="contacts-create-description"></textarea>
						</div>
					</div>

					<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

					<div style="position: relative;top: 15px;">
						<div class="form-group">
							<label for="contacts-create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="contacts-create-contactSummary"></textarea>
							</div>
						</div>
						<div class="form-group">
							<label for="contact-create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control myDate" id="contact-create-nextContactTime" readonly>
							</div>
						</div>
					</div>

					<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

					<div style="position: relative;top: 20px;">
						<div class="form-group">
							<label for="contacts-create-address" class="col-sm-2 control-label">详细地址</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="1" id="contacts-create-address"></textarea>
							</div>
						</div>
					</div>
				</form>

			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
				<button type="button" class="btn btn-primary" id="saveCreateContactsBtn">保存</button>
			</div>
		</div>
	</div>
	</div>

	<div class="modal fade" id="editRemarkModal" role="dialog">
	<%-- 备注的id --%>
	<input type="hidden" id="remarkId">
	<div class="modal-dialog" role="document" style="width: 40%;">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal">
					<span aria-hidden="true">×</span>
				</button>
				<h4 class="modal-title" id="myModalLabel1">修改备注</h4>
			</div>
			<div class="modal-body">
				<form class="form-horizontal" role="form">
					<input type="hidden" id="edit-id">
					<div class="form-group">
						<label for="edit-noteContent" class="col-sm-2 control-label">内容</label>
						<div class="col-sm-10" style="width: 81%;">
							<textarea class="form-control" rows="3" id="edit-noteContent"></textarea>
						</div>
					</div>
				</form>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
				<button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
			</div>
		</div>
	</div>
</div>

	<!-- 删除联系人的模态窗口 -->
	<div class="modal fade" id="removeContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 30%;">
			<input type="hidden" id="contactsId">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">删除联系人</h4>
				</div>
				<div class="modal-body">
					<p>您确定要删除该联系人吗？</p>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-danger" id="deleteContactsBtn">删除</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${customer.name} <small><a href="${customer.website}" target="_blank">${customer.website}</a></small></h3>
		</div>
	</div>
	
	<br/>
	<br/>
	<br/>

	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${customer.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${customer.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">公司网站</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${customer.website}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${customer.phone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${customer.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${customer.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${customer.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${customer.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 40px;">
            <div style="width: 300px; color: gray;">联系纪要</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
                    ${customer.contactSummary}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
        <div style="position: relative; left: 40px; height: 30px; top: 50px;">
            <div style="width: 300px; color: gray;">下次联系时间</div>
            <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${customer.nextContactTime}</b></div>
            <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
        </div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${customer.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 70px;">
            <div style="width: 300px; color: gray;">详细地址</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
                    ${customer.address}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
	</div>
	
	<!-- 备注 -->
	<div id="remarkDivList" style="position: relative; top: 10px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>

		<c:forEach items="${customerRemarkList}" var="customerRemark">
			<div id="div_${customerRemark.id}" class="remarkDiv" style="height: 60px;">
				<img title="${customerRemark.createBy}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
				<div style="position: relative; top: -40px; left: 40px;" >
					<h5>${customerRemark.noteContent}</h5>
					<font color="gray">客户</font> <font color="gray">-</font> <b>${customer.name}</b> <small style="color: gray;">${customerRemark.editFlag=='1'?customerRemark.editTime:customerRemark.createTime} 由${customerRemark.editFlag=='1'?customerRemark.editBy:c
					.createBy}${customerRemark.editFlag=='1'?'修改':'创建'}</small>
					<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
						<a class="myHref" name="editC" remarkId="${customerRemark.id}" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
						&nbsp;&nbsp;&nbsp;&nbsp;
						<a class="myHref" name="deleteC" remarkId="${customerRemark.id}" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
					</div>
				</div>
			</div>
		</c:forEach>
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button id="saveCreateCustomerRemarkBtn" type="button" class="btn btn-primary">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 交易 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>交易</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable2" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>金额</td>
							<td>阶段</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>类型</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="tBody">
					<c:forEach items="${tranList}" var="tran">
						<tr id="tr_${tran.id}">
							<td><a onclick="window.location.href='workbench/transaction/queryTranRemarkHistoryById.do?id=${tran.id}'" style="text-decoration: none;">${tran.name}</a></td>
							<td>${tran.money}</td>
							<td>${tran.stage}</td>
							<td>${tran.possibility}</td>
							<td>${tran.expectedDate}</td>
							<td>${tran.type}</td>
							<td><a href="javascript:void(0);" class="x" tranId="${tran.id}" data-toggle="modal" data-target="#unbundModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
						</tr>
					</c:forEach>
					</tbody>
				</table>
			</div>
			
			<%--<div>
				<a onclick="window.location.href='workbench/transaction/createPage.do';" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建交易</a>
			</div>--%>
		</div>
	</div>

	<!-- 联系人 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>联系人</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
					<tr style="color: #B3B3B3;">
						<td>名称</td>
						<td>邮箱</td>
						<td>手机</td>
						<td></td>
					</tr>
					</thead>
					<tbody id="contactsTBody">
					<c:forEach items="${contactsList}" var="contacts">
						<tr id="tr_${contacts.id}">
							<td><a onclick="window.location.href='workbench/contacts/DetailContacts.do?id=${contacts.id}'" style="text-decoration: none;">${contacts.fullname}</a></td>
							<td>${contacts.email}</td>
							<td>${contacts.mphone}</td>
							<td><a href="javascript:void(0);" contactsId="${contacts.id}" id="deleteContactsBtn1" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
						</tr>
					</c:forEach>
					<%--<tr>
						<td><a href="../contacts/detail.jsp" style="text-decoration: none;">李四</a></td>
						<td>lisi@bjpowernode.com</td>
						<td>13543645364</td>
						<td><a href="javascript:void(0);" data-toggle="modal" data-target="#removeContactsModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
					</tr>--%>
					</tbody>
				</table>
			</div>

			<%--<div>
				<a href="javascript:void(0);" id="createContactsBtn" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建联系人</a>
			</div>--%>
		</div>
	</div>

	<div style="height: 200px;"></div>
</body>
</html>