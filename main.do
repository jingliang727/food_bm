
* 1. 数据导入和初步处理
import excel "C:/Users/15480/Desktop/青山计划综合数据.xlsx", firstrow clear // 导入数据文件
describe // 查看数据结构
*数据集中的变量
*ID GreenMountainProject Donation FoodSavingCampaign LowCarbonConsumption SustainablePioneer2021 ModelAward2020 ModelAward2019 DonationAmount NoUtensilsOrder CarbonReduction Category ChineseBreakfast ChineseMeal Drinks AsianCuisine WesternFastFood WesternMeal Desserts Hotpot BBQFriedFood RiceandWheatNoodles FastFoodSnacks LightMeals Sales Min_Delivery Rating PerCapita HotSales PositiveReviews Price ReturningCustomers Service Taste Quality PortionSize Delivery Packaging District Xicheng Tongzhou Shunyi Shijingshan Haidian Fengtai Fangshan Dongcheng Daxing Chaoyang Changping Suburb District PM10 PM2.5 GreenArea PercapitaGreenArea GreenCoverageRate HarmlessWasteTreatment TotalEnergyConsumption EnergyConsumptionDeclineRate ResidentPopulation RegionalGDP	 PerCapitaDisposableIncome TotalRetailSales

*因变量
*FoodSavingCampaign LowCarbonConsumption Donation
*NoUtensilsOrder  CarbonReduction  DonationAmount 
*自变量
*SustainablePioneer2021 ModelAward2020 ModelAward2019
*Category Sales Min_Delivery Rating PerCapita Taste ReturningCustomers Service Quality Packaging Delivery  
*District PM10 PM2.5 GreenArea PercapitaGreenArea GreenCoverageRate HarmlessWasteTreatment TotalEnergyConsumption EnergyConsumptionDeclineRate ResidentPopulation RegionalGDP PerCapitaDisposableIncome TotalRetailSales

* 2. 数据清洗
encode Category, generate(new_category) // 对类别型变量进行编码
tab Category
encode District, generate(new_district)

* 对Category变量的编码赋予标签
label define category_labels ///
3 "AsianCuisine" ///
7 "BBQFriedFood" ///
1 "ChineseBreakfast" ///
2 "ChineseMeal" ///
5 "FastFoodSnacks" ///
6 "Hotpot" ///
4 "LightMeals" ///
9 "RiceandWheatNoodles" ///
10 "WesternFastFood" ///
11 "WesternMeal" ///
12 "Drinks" ///
8 "Desserts"
label values new_category category_labels

* 对District变量的编码赋予标签
*label define district_labels ///
*1 "Chaoyang" ///
*2 "Daxing" ///
*3 "Dongcheng" ///
*4 "Fengtai" ///
*5 "Haidian" ///
*6 "Shijingshan" ///
*7 "Suburb" ///
*8 "Tongzhou" ///
*9 "Xicheng"
*label values new_district district_labels

egen z_Sales = std(Sales)
egen z_Min_Delivery = std(Min_Delivery)
egen z_Rating = std(Rating)
egen z_PerCapita = std(PerCapita)

* 3. 描述性统计分析
tabulate new_category
summarize

* 4. 模型构建与估计
*GreenMountainProject	Donation	FoodSavingCampaign	LowCarbonConsumption	DonationAmount	NoUtensilsOrder	CarbonReduction

logit FoodSavingCampaign policy ib2.new_category Sales Min_Delivery Rating PerCapita, robust

* 筛选出特定店铺类型
keep if new_category == 5

* 运行逻辑回归模型
logit LowCarbonConsumption policy, robust



* 导出回归结果到Word文档，确保使用label选项
outreg2 using "FoodSavingCampaign.doc", replace label 

* 5. 计算并绘制ROC曲线和AUC值，评估模型的预测能力
lroc
lroc, graph

* 6. 检查多重共线性
vif, uncentered

* 7. 边际效应分析
margins, dydx(*) post


* 将边际效应结果追加到Word文档，再次确保使用label选项
outreg2 using "FoodSavingCampaign.doc", append label

* 8. 导出结果
* 结果已经在Word文档中
