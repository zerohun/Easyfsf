# encoding: utf-8
require 'spec_helper'
describe Easyfsf do
  describe "render charts" do
    it "render simple single chart" do
      render_sm_chart("a", "Pie2D", ['a','b','c'], [1,2,3]).should eq("<div id='aDiv' class='fusionchart'>\n\t\t\t\tChart.\n\t\t<fusionchartfree swf='/FusionChartsFree/Charts/FCF_Pie2D.swf' chart_id='a' chart_width='700' chart_height='500' chart_xml='<graph caption=\"\" subcaption=\"\" lineThickness=\"2\" showValues=\"0\" formatNumberScale=\"0\" anchorRadius=\"1\" divLineAlpha=\"20\" divLineColor=\"CC3300\" showAlternateHGridColor=\"1\" alternateHGridColor=\"CC3300\" rotateNames=\"1\" shadowAlpha=\"40\" numvdivlines=\"5\" chartLeftMargin=\"5\" chartRightMargin=\"5\" chartTopMargin=\"5\" chartBottomMargin=\"5\" bgColor=\"FFFFFF\" alternateHGridAlpha=\"5\" limitsDecimalPrecision=\"0\" divLineDecimalPrecision=\"0\" decimalPrecision=\"0\" yAxisMaxValue=\"10\"><set name=\"a\" value=\"1\" color=\"\"/><set name=\"b\" value=\"2\" color=\"\"/><set name=\"c\" value=\"3\" color=\"\"/></graph>' /></div>")
    end
    
    it "render simple multie chart" do
      render_sm_chart("b", "Column3D", ['a','b','c'], [{:seriesName => "se1", :color => "FF0000",:value_list => [1,2,3]}, {:seriesName => "se2", :color => "F660AB", :value_list => [3,4,5]}]).should eq("<div id='bDiv' class='fusionchart'>\n\t\t\t\tChart.\n\t\t<fusionchartfree swf='/FusionChartsFree/Charts/FCF_MSColumn3D.swf' chart_id='b' chart_width='700' chart_height='500' chart_xml='<graph caption=\"\" subcaption=\"\" lineThickness=\"2\" showValues=\"0\" formatNumberScale=\"0\" anchorRadius=\"1\" divLineAlpha=\"20\" divLineColor=\"CC3300\" showAlternateHGridColor=\"1\" alternateHGridColor=\"CC3300\" rotateNames=\"1\" shadowAlpha=\"40\" numvdivlines=\"5\" chartLeftMargin=\"5\" chartRightMargin=\"5\" chartTopMargin=\"5\" chartBottomMargin=\"5\" bgColor=\"FFFFFF\" alternateHGridAlpha=\"5\" limitsDecimalPrecision=\"0\" divLineDecimalPrecision=\"0\" decimalPrecision=\"0\" yAxisMaxValue=\"10\"><categories><category name=\"a\"/><category name=\"b\"/><category name=\"c\"/></categories><dataset seriesName=\"se1\" color=\"FF0000\"><set value=\"1\"/><set value=\"2\"/><set value=\"3\"/></dataset><dataset seriesName=\"se2\" color=\"F660AB\"><set value=\"3\"/><set value=\"4\"/><set value=\"5\"/></dataset></graph>' /></div>")
    end
  end
end