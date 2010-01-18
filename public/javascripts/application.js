function nav(url)
{
    window.location.href = url;
}
function dashboard_nav(nav_type, agency_id)
{
	// get the client id
	var client_id = document.getElementById('client_id').value;
	
	if (nav_type == "create_contract")
	{
		nav("/clients/" + client_id + "/contracts/new");
	}
	else if (nav_type == "add_approver")
	{
		nav("/clients/" + client_id + "/new_approver");
	}
	else
	{
		nav("/agencies/" + agency_id + "/invite_workers");
	}
	
	return true;
}
function open_help(url, title, width, height)
{
  window.open(url, "Help", "width=" + width + ",height=" + height + ",resizable,scrollbars=yes");
}
function get_login()
{
    return document.getElementById('login').value;
}
function checkAllowOvertime(id)
{
    var val = document.getElementById(id).value;
    if (val == "true")
    {
        document.getElementById('overtimehourp').disabled = false;
        document.getElementById('overtimehourp').value = "0.00";
        document.getElementById('overtimehourc').disabled = false;
        document.getElementById('overtimehourc').value = "0.00";
    }
    else
    {
        document.getElementById('overtimehourp').disabled = true;
        document.getElementById('overtimehourp').value = "";
        document.getElementById('overtimehourc').disabled = true;
        document.getElementById('overtimehourc').value = "";
    }
}
function checkDailyRate(id)
{
    var val = document.getElementById(id).value;
    if (val == "Day")
    {
        document.getElementById('standarddayp').disabled = false;
        document.getElementById('standarddayp').value = "0.00";
        document.getElementById('standarddayc').disabled = false;
        document.getElementById('standarddayc').value = "0.00";
        document.getElementById('standardhourp').disabled = true;
        document.getElementById('standardhourp').value = "";
        document.getElementById('standardhourc').disabled = true;
        document.getElementById('standardhourc').value = "";
    }
    else
    {
        document.getElementById('standarddayp').disabled = true;
        document.getElementById('standarddayp').value = "";
        document.getElementById('standarddayc').disabled = true;
        document.getElementById('standarddayc').value = "";
        document.getElementById('standardhourp').disabled = false;
        document.getElementById('standardhourp').value = "0.00";
        document.getElementById('standardhourc').disabled = false;
        document.getElementById('standardhourc').value = "0.00";
    }
}
function display_errors(title, msgs)
{
    var header = "<div class=\"bold alert_msg\">" + title + "</div><br />";
        
    if (msgs != null && msgs != "") {
        $('error_msgs').innerHTML = header + "<div style=\"margin-left:12px\">" + msgs + '</div>';
        $('error_msgs').style.display = '';
        var errors = RUZEE.ShadedBorder.create({corner:8, border:1});
        errors.render($('error_msgs'));
        
    }
}
function display_notice(message)
{
    if (message != null && message != "" ) {
        $('notice').innerHTML = '<div class=\"bold alert_msg\">' + message + '</div>';
        $('notice').style.display = '';
        var notice = RUZEE.ShadedBorder.create({corner:8, border:1});
        notice.render($('notice'));
    }
}
function set_admin()
{
    var admin = document.getElementById('user_admin').checked;
    if (admin == true)
    {
        document.getElementById('user_manager').checked = true;
        document.getElementById('settings').checked = true;
        document.getElementById('invoicing').checked = true;
        document.getElementById('reports').checked = true;
    }
    else
    {
        document.getElementById('user_manager').checked = false;
        document.getElementById('settings').checked = false;
        document.getElementById('invoicing').checked = false;
        document.getElementById('reports').checked = false;
    }
}

function check_admin(is_user_manager)
{
    var user_manager_selected = document.getElementById('user_manager').checked;
    var settings_selected = document.getElementById('settings').checked;
    var invoicing_selected = document.getElementById('invoicing').checked;
    var reports_selected = document.getElementById('reports').checked;

    if (is_user_manager != null && is_user_manager == 'true' && user_manager_selected == false)
        alert("WARNING: If you remove the User Manager role, you will lose access to the Users screen immediately!");

    if (user_manager_selected == false || settings_selected == false || invoicing_selected == false || reports_selected == false)
        document.getElementById('user_admin').checked = false;
    else 
        document.getElementById('user_admin').checked = true;
}

function limitText(limitField, limitNum) {
    if (limitField.value.length > limitNum) {
        limitField.value = limitField.value.substring(0, limitNum);
    }
}

function setEntryDate(id)
{
    document.getElementById('selected_date').value = document.getElementById('timesheet_timesheet_entries_attributes_' + id + '_dateValue').value;
	//alert(document.getElementById('selected_date').value);
	return true;

}
function formatTime(id)
{
    var text = document.getElementById(id).value;

    // prepend with a zero if needed
    if (text.length == 1 && parseInt(text[0]) > 2)
        text = "0" + text;
  
    if (text.length == 2)
    {
        document.getElementById(id).value = text + ':';
    }
    else if (text.length > 5)
    {
        document.getElementById(id).value = text.substring(0,5);
    }
}

function set_day_total(counter, total)
{
    var start = document.getElementById('startTime' + counter).value
    var brk = document.getElementById('breakHours' + counter).value
    var end = document.getElementById('finishTime' + counter).value
    var one_hr=1000*60*60;
    var breakValue = 0

    if (start.length == 3)
    {
        start = start + "00";
        document.getElementById('startTime' + counter).value = start;
    }

    if (end.length == 3)
    {
        end = end + "00";
        document.getElementById('finishTime' + counter).value = end;
    }

    var shrs = start.substring(0,start.indexOf(":"));
    var smins = start.substring(start.indexOf(":")+1);
    var sDate = new Date(2009, 1, 1, parseInt(shrs, 10), parseInt(smins, 10), 1, 1);
    var fhrs = end.substring(0,end.indexOf(":"));
    var fmins = end.substring(end.indexOf(":")+1);
    var fDate = new Date(2009, 1, 1, parseInt(fhrs, 10), parseInt(fmins, 10), 1, 1);

    if (brk != null && brk != "")
    {
        var leftBrk = brk.substring(0,brk.indexOf(":"));
        var rightBrk = brk.substring(brk.indexOf(":")+1);

        switch(rightBrk)
        {
            case "15":
                rightBrk = "25";
                break;
            case "30":
                rightBrk = "50";
                break;
            case "45":
                rightBrk = "75";
                break;
        }

        breakValue = parseFloat(leftBrk + "." + rightBrk)*60*60*1000;
    }
        
    var range = (((fDate.getTime() - sDate.getTime()) - breakValue)/one_hr);
    if (range != null && range != NaN && range > 0)
    {
        document.getElementById('hours' + counter).value = range.toString();
        formatHours('hours' + counter, total);
    }
}

function formatHours(id, total)
{
    var text = document.getElementById(id).value;

    var decimalPointIndex = text.indexOf(".");
    if (text.indexOf(":") > -1)
    {
        // do nothing
    }
    else if (text == "")
    {
        // do nothing
    }
    else if (decimalPointIndex > -1)
    {
        // decimal convert
        var leftSide = text.substring(0,decimalPointIndex);
        //if (leftSide.length == 1)
        //    leftSide = "0" + leftSide;
        if (leftSide == "")
            leftSide = "0";
        var right = text.substring(decimalPointIndex+1);
        var units = parseInt(right);
        var rightSide = ":00";
        
        switch(units)
        {
            case 5: 
                rightSide = ":30";
                break;
            case 25:
                rightSide = ":15";
                break;
            case 75:
                rightSide = ":45";
        }
        
        document.getElementById(id).value = leftSide + rightSide;

    }
    else if (text.length < 3)
    {
        document.getElementById(id).value = text + ":00";

    }
    else if (text.length == 4)
    {
        var newVal = text.substring(0,2)
        newVal += ":"
        newVal += text.substring(2);
        document.getElementById(id).value = newVal;
    }
    
    CalcTotalHours(total);
}

function CalcAll(total)
{
  CalcTotalHours(total);
  CalcTotalDays(total);

}
function CalcTotalHours(total)
{
    var totalLeft = 0.0;
    var totalRight = 0.0;
    
    for(i=0;i<total;i++)
    {
        var obj = document.getElementById('hours' + i.toString());

        if (obj == null)
            continue;
        
        var time = obj.value;
        
        if (time != "")
        {
            var colonIndex = time.indexOf(":");
            if (colonIndex == -1)
                return;

            var left = time.substring(0, colonIndex);
            //alert('left: ' + left);
            
            var right = time.substring(colonIndex + 1);
            //alert('right: ' + right);
            
            totalLeft += parseFloat(left);
            //alert('totalLeft: ' + totalLeft);
            totalRight += parseFloat(right);
            //alert('totalRight: ' + totalRight);
        }
        
        obj = document.getElementById('hours' + i.toString());
    }

    //alert('totalleft: ' + totalLeft);
    var leftAsMins = totalLeft*60;
    //alert('leftAsMins: ' + leftAsMins);
    var totalMins = leftAsMins+totalRight;
    //alert('totalMins: ' + totalMins);
    var hoursAsDecimal = totalMins/60;
    //alert('hoursAsDecimal: ' + hoursAsDecimal);
    var wholeHours = parseInt(hoursAsDecimal);
    //alert('wholeHours: ' + wholeHours);
    var remainder = hoursAsDecimal-wholeHours;
    //alert('remainder: ' + remainder);
    var mins = ((remainder*100)/5)*3;
    //alert('mins: ' + mins);
    var total = wholeHours.toString() + ":" + mins.toString();
    //alert('total: ' + total);
    var totalAsString = total.toString();
    //if (totalAsString.length == 4)
    //    totalAsString += "0";
    if (totalAsString.endsWith(":0"))
        totalAsString += "0";
    document.getElementById('totalStandard').innerHTML = totalAsString;

}
function CalcTotalCalls(total)
{
    var iTotal = parseInt(total);
    var obj = "1";
    var totalOnCall = 0;

    for(i=0;i<iTtotal;i++)
    {
        obj = document.getElementById('onCall' + i);
        if (obj != null)
        {
            if (obj.checked)
                totalOnCall++;

        }
    }

    document.getElementById('totalOnCall').innerHTML = totalOnCall.toString();

}
function CalcTotalDays(total)
{
    var totalDays = 0.0;
    
    for(i=0;i<total;i++)
    {
        var day = document.getElementById('dayValue' + i.toString());
        if (day.value != "")
        {
            totalDays += parseFloat(day.value);
        }
        
    }
    
    document.getElementById('totalDays').innerHTML = totalDays.toString();
}

function applyDayRateMargin(niRate, holRate)
{
    var margin = parseFloat(document.getElementById('contract_margin').value);
    if (margin == null || margin == 0)
        return;
    var chargeAsPAYE = document.getElementById('calcChargeAsPAYE').checked;
    var payRate = parseFloat(document.getElementById('dayrate').value);
    if (payRate == null || payRate == "" || payRate == "0")
        return;
    var chargeRate = 0.0;
    if (chargeAsPAYE)
    {
        var niAmt = payRate * (parseFloat(niRate)/100);
        var holAmt = payRate * (parseFloat(holRate)/100);
        chargeRate = (payRate + niAmt + holAmt);
        chargeRate = chargeRate + parseFloat(chargeRate * (margin/100));
        document.getElementById('daychargerate').value = chargeRate.toFixed(2);
    }
    else
    {
        chargeRate = payRate + (payRate * (margin/100));
        document.getElementById('daychargerate').value = chargeRate.toFixed(2);
    }
    document.getElementById('dayrate').value = payRate.toFixed(2)
}

function applyMargin(id, niRate, holRate)
{
    var margin = document.getElementById('contract_margin').value;
    if (margin == null || margin == 0)
        return;
    var chargeAsPAYE = document.getElementById('calcChargeAsPAYE').checked;
    var payRate = parseFloat(document.getElementById(id + 'p').value);
    
    if (chargeAsPAYE == '1')
    {
        var niAmt = payRate * (parseFloat(niRate)/100);
        var holAmt = payRate * (parseFloat(holRate)/100);
        var chargeRate = (payRate + niAmt + holAmt);
        chargeRate = chargeRate + parseFloat(chargeRate * (margin/100));
        document.getElementById(id + 'c').value = chargeRate.toFixed(2);
        
    }
    else
    {
        document.getElementById(id + 'c').value = (parseFloat(payRate) + (parseFloat(payRate) * (margin/100))).toFixed(2);
    }
    document.getElementById(id + 'p').value = payRate.toFixed(2)
}

function applyMargin2(niRate, holRate, margin)
{
    if (margin == null || margin == 0)
        return;

    var payRate = parseFloat(document.getElementById('rate_payRate').value);
    var niAmt = payRate * (parseFloat(niRate)/100);
    var holAmt = payRate * (parseFloat(holRate)/100);
    var chargeRate = (payRate + niAmt + holAmt);
    chargeRate = chargeRate + parseFloat(chargeRate * (margin/100));
    document.getElementById('rate_chargeRate').value = chargeRate.toFixed(2);
    document.getElementById('rate_payRate').value = payRate.toFixed(2);
}

function disableDayRate()
{
    selectedRateType = document.getElementById('rateType').value;
    
    if (selectedRateType == 'Hour')
    {
        document.getElementById('contract_dayRate').disabled = true;
        document.getElementById('contract_dayRate').value = "";
    }
    else
    {
        document.getElementById('contract_dayRate').disabled = false;
    }
}

function rateEnable(rate)
{
    if (rate == 'hour')
    {
        // disable day - enable hour
        document.getElementById('dayrate').disabled = true;
        document.getElementById('dayrate').value = "";
        document.getElementById('daychargerate').disabled = true;
        document.getElementById('daychargerate').value = "";

        document.getElementById('standardp').disabled = false;
        document.getElementById('standardc').disabled = false;
        document.getElementById('overtimep').disabled = false;
        document.getElementById('overtimec').disabled = false;
        document.getElementById('bankholidayp').disabled = false;
        document.getElementById('bankholidayc').disabled = false;
        
    }
    else
    {
        // enable day - disable hour
        document.getElementById('dayrate').disabled = false;
        document.getElementById('daychargerate').disabled = false;
        document.getElementById('standardp').disabled = true;
        document.getElementById('standardp').value = "";
        document.getElementById('standardc').disabled = true;
        document.getElementById('standardc').value = "";
        document.getElementById('overtimep').disabled = true;
        document.getElementById('overtimep').value = "";
        document.getElementById('overtimec').disabled = true;
        document.getElementById('overtimec').value = "";
        document.getElementById('bankholidayp').disabled = true;
        document.getElementById('bankholidayp').value = "";
        document.getElementById('bankholidayc').disabled = true;
        document.getElementById('bankholidayc').value = "";
       
    }

}