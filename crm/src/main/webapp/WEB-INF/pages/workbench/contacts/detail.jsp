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

		$("#saveCreateContactsRemarkBtn").click(function () {
			let contactsId='${contacts.id}';
			let noteContent=$.trim($("#remark").val());
			if (noteContent==""){
				alert("备注不能为空");
				return;
			}
			$.ajax({
				url:"workbench/contacts/saveCreateContactsRemark.do",
				data:{
					contactsId:contactsId,
					noteContent:noteContent
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
						htmlStr+="<font color=\"gray\">联系人</font> <font color=\"gray\">-</font> <b>${contacts.fullname}${contacts.appellation}-${contacts.customerId}</b> <small style=\"color: gray;\"> "+data.retData.createTime+" 由${sessionScope.sessionUser.name}创建</small>";
						htmlStr+="<div style=\"position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;\">";
						htmlStr+="<a class=\"myHref\" name=\"editA\" remarkId=\""+data.retData.id+"\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-edit\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
						htmlStr+="&nbsp;&nbsp;&nbsp;&nbsp;";
						htmlStr+="<a class=\"myHref\" name=\"deleteA\" remarkId=\""+data.retData.id+"\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-remove\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
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
				url:"workbench/contacts/saveEditContactsRemark.do",
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
				url:"workbench/contacts/saveDeleteContactsRemarkById.do",
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

		$("#TranTBody").on("click","a.x",function () {
			let id=$(this).attr("tranId");
			if(window.confirm("确定删除吗?")){
				$.ajax({
					url:"workbench/contacts/saveDeleteTran.do",
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

		$("#boundActivityBtn").click(function () {
			$("#searchActivityTxt").val("");
			searchActivityByName();
			$("#boundActivityModal").modal("show");
		});

		$("#searchActivityTxt").keyup(function () {
			searchActivityByName();
		});

		$("#checkAll").click(function () {
			$("#tBody input[type='checkbox']").prop("checked",this.checked)
		})

		$("#saveBoundActivityBtn").click(function () {
			let checkedId=$("#tBody input[type='checkbox']:checked");
			if(checkedId.size()==0){
				alert("请选择要关联的市场活动");
				return;
			}
			let ids="";
			$.each(checkedId,function () {
				ids+="activityId="+this.value+"&";
			});

			ids+="contactsId=${contacts.id}";
			$.ajax({
				url:"workbench/contacts/saveBound.do",
				data:ids,
				type:"post",
				dataType:"json",
				success:function (data) {
					if(data.code=="1"){
						$("#boundActivityModal").modal("hide");
						let htmlStr="";
						$.each(data.retData,function (index,obj) {
							htmlStr+="<tr id=\"tr_"+obj.id+"\">";
							htmlStr+="<td><a onclick=\"window.location.href='workbench/activity/detailActivity.do?id="+obj.id+"';\" style=\"text-decoration: none;\">"+obj.name+"</a></td>";
							htmlStr+="<td>"+obj.startDate+"</td>";
							htmlStr+="<td>"+obj.endDate+"</td>";
							htmlStr+="<td>"+obj.owner+"</td>";
							htmlStr+="<td><a href=\"javascript:void(0);\" activityId=\""+obj.id+"\"  style=\"text-decoration: none;\"><span class=\"glyphicon glyphicon-remove\"></span>解除关联</a></td>";
							htmlStr+="</tr>";
						})
						$("#ActivityTBody").append(htmlStr);
					}else{
						$("#boundActivityModal").modal("show");
						alert(data.message);
					}
				}
			});
		})

		$("#ActivityTBody").on("click","a.x",function () {
			$("#unboundActivityModal").modal("show");
			$("#activityId").val($(this).attr("activityId"));
		});

		$("#UnBoundBtn").click(function (){
			let activityId=$("#activityId").val();
			let contactsId='${contacts.id}';
			$.ajax({
				url:"workbench/contacts/deleteBound.do",
				data:{
					activityId:activityId,
					contactsId:contactsId
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					if(data.code=="1"){
						$("#unboundActivityModal").modal("hide");
						$("#tr_"+activityId).remove();
					}else{
						alert(data.message);
					}
				}
			});
		});

	});

	function searchActivityByName(){
		let activityName=$("#searchActivityTxt").val();
		let contactsId='${contacts.id}';
		$.ajax({
			url:"workbench/contacts/queryActivityForDetailByNameContactsId.do",
			data:{
				activityName:activityName,
				clueId:contactsId
			},
			type:"post",
			datatype:"json",
			success:function (data) {
				let htmlStr="";
				$.each(data,function (index,obj) {
					htmlStr+="<tr>"
					htmlStr+="<td><input type=\"checkbox\" value=\""+obj.id+"\"/></td>"
					htmlStr+="<td>"+obj.name+"</td>"
					htmlStr+="<td>"+obj.startDate+"</td>"
					htmlStr+="<td>"+obj.endDate+"</td>"
					htmlStr+="<td>"+obj.owner+"</td>"
					htmlStr+="</tr>"
				})
				$("#tBody").html(htmlStr);
			}
		})
	}
</script>

</head>
<body>
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

	<!-- 解除联系人和市场活动关联的模态窗口 -->
	<div class="modal fade" id="unboundActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 30%;">
			<input type="hidden" id="activityId">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">解除关联</h4>
				</div>
				<div class="modal-body">
					<p>您确定要解除该关联关系吗？</p>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" id="UnBoundBtn">解除</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 联系人和市场活动关联的模态窗口 -->
	<div class="modal fade" id="boundActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">关联市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" id="searchActivityTxt" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable2" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td><input type="checkbox" id="checkAll"/></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="tBody">
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" id="saveBoundActivityBtn">关联</button>
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
			<h3>${contacts.fullname}${contacts.appellation} <small> - ${contacts.customerId}</small></h3>
		</div>
		<%--<div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" data-toggle="modal" data-target="#editContactsModal"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>--%>
	</div>
	
	<br/>
	<br/>
	<br/>

	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${contacts.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">来源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${contacts.source}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">客户名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${contacts.customerId}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">姓名</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${contacts.fullname}${contacts.appellation}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">邮箱</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${contacts.email}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">手机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${contacts.mphone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">职位</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${contacts.job}</b></div>
			<%--<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">生日</div>--%>
			<%--<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;</b></div>--%>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
			<%--<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>--%>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${contacts.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${contacts.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${contacts.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${contacts.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${contacts.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
                    ${contacts.contactSummary}
					&nbsp;
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${contacts.nextContactTime}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 90px;">
            <div style="width: 300px; color: gray;">详细地址</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
                    ${contacts.address}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
	</div>
	<!-- 备注 -->
	<div style="position: relative; top: 20px; left: 40px;" id="remarkDivList">
		<div class="page-header">
			<h4>备注</h4>
		</div>

        <c:forEach items="${contactsRemarkList}" var="contactsRemark">
            <div id="div_${contactsRemark.id}" class="remarkDiv" style="height: 60px;">
                <img title="${contactsRemark.createBy}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
                <div style="position: relative; top: -40px; left: 40px;" >
                    <h5>${contactsRemark.noteContent}</h5>
                    <font color="gray">联系人</font> <font color="gray">-</font> <b>${contacts.fullname}${contacts.appellation}-${contacts.customerId}</b> <small style="color: gray;"> ${contactsRemark.editFlag=='1'?contactsRemark.editTime:contactsRemark.createTime} 由${contactsRemark.editFlag=='1'?contactsRemark.editBy:contactsRemark.createBy}${contactsRemark.editFlag=='1'?'修改':'创建'}</small>
                    <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                        <a class="myHref" name="editC"  remarkId="${contactsRemark.id}" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
                        &nbsp;&nbsp;&nbsp;&nbsp;
                        <a class="myHref" name="deleteC" remarkId="${contactsRemark.id}" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
                    </div>
                </div>
            </div>
        </c:forEach>
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="saveCreateContactsRemarkBtn">保存</button>
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
				<table id="activityTable3" class="table table-hover" style="width: 900px;">
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
					<tbody id="TranTBody">
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
	
	<!-- 市场活动 -->
	<div>
		<div style="position: relative; top: 60px; left: 40px;">
			<div class="page-header">
				<h4>市场活动</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>开始日期</td>
							<td>结束日期</td>
							<td>所有者</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="ActivityTBody">
					<c:forEach items="${activityList}" var="activity">
						<tr>
							<td><a onclick="window.location.href='workbench/activity/detailActivity.do?id=${activity.id}';" style="text-decoration: none;">${activity.name}</a></td>
							<td>${activity.startDate}</td>
							<td>${activity.endDate}</td>
							<td>${activity.owner}</td>
							<td><a href="javascript:void(0);" class="x" activityId="${activity.id}" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>
						</tr>
					</c:forEach>
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="javascript:void(0);" id="boundActivityBtn" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>关联市场活动</a>
			</div>
		</div>
	</div>
	
	
	<div style="height: 200px;"></div>
</body>
</html>