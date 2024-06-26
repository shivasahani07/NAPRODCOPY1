public class WeekNumberUtility {
    // Method to get the week number of the year
    public static boolean identifyWeekNumber() {
        Integer weekCounter = 0;
        Date currentDate = Date.today();
        DateTime dateTimeValue = currentDate;
        DateTime monthStartDate = currentDate.toStartOfMonth();
        Integer totalMonthDays = date.daysInMonth(currentDate.year(),currentDate.month());
        for(Integer i=currentDate.toStartOfMonth().day();i<totalMonthDays;i++){
            system.debug('i::'+i);
            system.debug('monthStartDate::'+monthStartDate);
            if(monthStartDate.isSameDay(currentDate)){
                break;
            }else if(monthStartDate.format('EEEE') == 'Sunday'){
                ++weekCounter;
            }
                monthStartDate = monthStartDate.addDays(1);
            system.debug('monthStartDate::'+monthStartDate);
        }
        
        if (weekCounter != 0 && math.mod(weekCounter+1, 2) == 0) {
            return true;
        }else{
            return false;
        }
    }
}