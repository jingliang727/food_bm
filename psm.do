
* 加载数据
import excel "C:/Users/Administrator/Desktop/稳健性检验.xlsx", firstrow clear // 

* 1. 定义处理变量
gen treated = (policy == 1)  // 假设'policy'为1表示实施了政策
egen std_Sales = std(Sales)
egen std_Min_Delivery = std(Min_Delivery)
egen std_Rating = std(Rating)
egen std_PerCapita = std(PerCapita)


* 2. 数据清洗
encode Tcategory, generate(new_category) // 对类别型变量进行编码

* 对Category变量的编码赋予标签
label define category_labels ///
1 "ChineseBreakfast" ///
2 "ChineseMeal" ///
3 "AsianCuisine" ///
4 "LightMeals" ///
5 "FastFoodSnacks" ///
6 "Hotpot" ///
7 "BBQFriedFood" ///
8 "Desserts" ///
9 "RiceandWheatNoodles" ///
10 "WesternFastFood" ///
11 "WesternMeal" ///
12 "Drinks" 
label values new_category category_labels

* 为了便于匹配，将地区变量编码为数字
gen district_num = .
replace district_num = 1 if Tdistrict == "朝阳区" | Tdistrict == "天河区"
replace district_num = 2 if Tdistrict == "丰台区" | Tdistrict == "白云区"
replace district_num = 3 if Tdistrict == "海淀区" | Tdistrict == "越秀区"
replace district_num = 4 if Tdistrict == "西城区" | Tdistrict == "黄埔区"
replace district_num = 5 if Tdistrict == "东城区" | Tdistrict == "海珠区"
replace district_num = 6 if Tdistrict == "石景山区" | Tdistrict == "荔湾区"
replace district_num = 7 if Tdistrict == "北近郊区" | Tdistrict == "广近郊区"
replace district_num = 8 if Tdistrict == "北远郊区" | Tdistrict == "广远郊区"

* 循环进行PSM匹配
foreach d in 1 2 3 4 5 6 7 8 {
	* 根据地区分组创建临时数据子集
    preserve
    keep if district_num == `d'
	
	* 根据地区分组估计倾向得分
    logit policy ib2.new_category Chain std_Sales std_Min_Delivery std_Rating std_PerCapita 
    predict pscore`d', p

    * 使用倾向得分进行匹配
    psmatch2 policy, kernel pscore(pscore)
	
	* 检查匹配后的协变量平衡性
    pstest ib2.new_category Chain std_Sales std_Min_Delivery std_Rating std_PerCapita, graph	
	
	* 保存匹配结果图表到桌面为 .gph 格式
    graph save "C:/Users/Administrator/Desktop/pstest_district_`d'.gph", replace
	
	* 保存匹配结果
    tempfile matched_district_`d'
    save "matched_district_`d'.dta", replace

    * 恢复原始数据集
    restore
}

* 合并匹配结果
use "matched_district_1.dta", clear
forvalues i = 2/8 {
    append using "matched_district_`i'.dta"
}

* 进行逻辑回归，以policy为因变量
logit GreenMountainProject policy ib2.new_category Chain std_Sales std_Min_Delivery std_Rating std_PerCapita [pw=_weight], robust 
*GreenMountainProject FoodSavingCampaign LowCarbonConsumption Donation DonationAmount NoUtensilsOrder CarbonReduction

* 导出逻辑回归结果
outreg2 using "C:/Users/Administrator/Desktop/logistic_regression_results1.doc", replace

margins, dydx(*) post   

// 输出结果
outreg2 using "C:/Users/Administrator/Desktop/logistic_regression_results.doc", replace


