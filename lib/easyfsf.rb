require "easyfsf/version"
require "easyfsf/application_helper" if defined? Rails
require "builder"


module Easyfsf

  #To render single chart or multi chart, call <tt>render_sm_chart</tt>
  #Depends on parameter it render single data chart or multi data chart
  #You can use this method as helper
  #
  #<%= render_sm_chart("a", "Pie2D", ['a','b','c'], [1,2,3]) %>
  #
  #<%= render_sm_chart("b", "Column3D", ['a','b','c'], [{:seriesName => "se1", :color => "FF0000",:value_list => [1,2,3]}, {:seriesName => "se2", :color => "F660AB", :value_list => [3,4,5]}]) %>
  #<%= render_sm_chart("b", "Column3D", ['a','b','c'], [{:seriesName => "se1", :color => "FF0000",:value_list => [1,2,3]}, {:seriesName => "se2", :color => "F660AB", :value_list => [3,4,5]}],{}, 500, 400, true) %>
  #
  #for detail infomation visit http://zerohun.wordpress.com/2012/01/06/easyfsf/
  #for the options parameter visit http://docs.fusioncharts.com/charts/
  
  def render_sm_chart(chart_id, chart_type, category, datasets, options = {}, chart_width = 700, chart_height = 500, show_total = false)
    
    options = options.clone if options.present?
    category = FCFInitializer.standardize_category(category)
    datasets = FCFInitializer.standardize_datasets(datasets)
    
    if options[:skipCategory].present?
      category = FCFInitializer.skip_category(category, 10)
      options.delete :skipCategory
    end
    
    isMultiChart = datasets.length > 1
    chart_swf = FCFInitializer.get_swf_file_name(chart_type, isMultiChart)
    options = FCFInitializer.get_default_option.merge(options)
    chart_html = ""
    if show_total == true
      chart_html << "<div id=#{chart_id}Div_total><br />"
      datasets.each do |dataset|
        total = 0
        dataset[:value_list].each do |value|
          total += value
        end
        chart_html << "<p>Total #{dataset[:seriesName]} : #{total}</p>"
      end
      chart_html << "<br /></div>"
    end
    xmlString = FCFChartXmlBuilder.smchart_xml(category, datasets, options)
    chart_html << FCFRenderer.render_chart("/FusionChartsFree/Charts/#{chart_swf}", xmlString, chart_id, chart_width, chart_height)
    return chart_html.html_safe
  end
  

  
  module FCFInitializer
    #default optinoss
    DEFAULT_OPTIONS = {
          :caption                   => "",
          :subcaption                => "",
          :lineThickness             => "5",
          :showValues                => "0",
          :formatNumberScale         => "0", 
          :anchorRadius              => "5", 
          :divLineAlpha              => "20" ,
          :divLineColor              => "CC3300", 
          :showAlternateHGridColor   => "1", 
          :alternateHGridColor       => "CC3300",
          :rotateNames               => "1",
          :shadowAlpha               => "40",  
          :numvdivlines              => "5", 
          :chartLeftMargin           => "5", 
          :chartRightMargin          => "5", 
          :chartTopMargin            => "5", 
          :chartBottomMargin         => "5", 
          :bgColor                   => "FFFFFF", 
          :alternateHGridAlpha       => "5", 
          :limitsDecimalPrecision    => '0', 
          :divLineDecimalPrecision   => '0',
          :decimalPrecision          => "0",
          :yAxisMaxValue             => "10",
          :lineThickness             => "2",
          :anchorRadius              => "1"
    }      
        


    #to file swf files
    #chart difinition for rendering single chart
    ONLY_SINGLE_CHART = ["Pie2D", "Pie3D", "Funnel"]
    
    #chart difinition for rendering multi chart
    ONLY_MULTI_CHART = ["StackedArea2D", "StackedBar2D", "StackedColumn2D", 
                        "StackedColumn3D", "MSColumn2DLineDY", "MSColumn3DLineDY"]
    
    #chart difinition for rendering single and multi chart
    BOTH_CAPABLE_CHART = ["Line", "Area2D", "Bar2D", "Column2D", "Column3D"]    
    @chartIdList = []
    
    def self.get_default_option
      DEFAULT_OPTIONS
    end
    

    def self.get_swf_file_name(chart_type, isMulti)
      if ONLY_SINGLE_CHART.include? chart_type 
        if isMulti
          raise ArgumentError, "#{chart_type} can draw only single chart data but it's multichart data"
        else
          return "FCF_#{chart_type}.swf"
        end
      end
      if ONLY_MULTI_CHART.include? chart_type
        if isMulti
          return "FCF_#{chart_type}.swf"
        else
          raise ArgumentError, "#{chart_type} can draw only multichart data but it's singlechart data"
        end
      end
      if BOTH_CAPABLE_CHART.include? chart_type
        if isMulti
          return "FCF_MS#{chart_type}.swf"
        else
          return "FCF_#{chart_type}.swf"
        end      
      end
      raise ArgumentError, "there is no #{chart_type} type"   
    end
    

    def self.standardize_category(category)
      case check_category_params(category)
      when :STRING_ARRAY  
        return {:value_list => category.map {|c| c.to_s}}
      when :HASH
        return category.clone
      else
        raise ArgumentError, 
              "First parameter should be Hash, Array of String or Array of something that can be converted to String"  
      end        
    end
      

    def self.standardize_datasets(datasets)
      case check_datasets_params(datasets)
      when :NUM_ARRAY
        return [{:value_list => datasets}]
      when :HASH_ARRAY
        clonedDataSets = []
        datasets.each do |dataset|
          clonedDataSets << dataset.clone
        end
        return clonedDataSets
      when :HASH
        return [datasets.clone]
      else
        raise ArgumentError, 
          "parameters should be Hash, Array of Hash , Array of Fixum or Array of Float"             
      end
    end
    def self.check_category_params(category)
      if category.is_a? Array
        return :STRING_ARRAY if category[0].respond_to?(:to_s)
      end
      if category.is_a? Hash
        return :HASH         if category[:value_list]
      end
      return :SOMETHING_ELSE
    end
            
    def self.check_datasets_params(datasets)
      if datasets.is_a? Array 
        return :NUM_ARRAY  if datasets[0].is_a? Fixnum or datasets[0].is_a? Float
        if datasets[0].is_a? Hash
          datasets.each_with_index do |dataset, index|
            raise ArgumentError, 
                "There is a nil value_list in datasets(name: #{dataset[:seriesName]} ,index:#{index})" if dataset[:value_list].blank?
          end
          return :HASH_ARRAY
        end
      end
      if datasets.is_a? Hash
        return :HASH if datasets[:value_list].present?
      end
      return :SOMETHING_ELSE
    end    
    
    #skipSize에 맞춰 category의 value_list를 빈 문자열로 교체합니다.
    def self.skip_category(category, skipSize)
      newValueList = category[:value_list].each_with_index.map{ |value,index|
        next value if (index+1)%(skipSize+1) == 1
        next ""
        }
      return category.merge(:value_list => newValueList)
    end
  end
  
  module FCFRenderer
    #차트의 xml 데이타를 <fusionchatfree />형식으로 나타내어서 javascript 코드에서 파싱해서
    #차트를 그려줄 수 있게끔 합니다. 
    def self.render_chart(chart_swf, chart_xml, chart_id , chart_width, chart_height) 
      chart_width=chart_width.to_s
      chart_height=chart_height.to_s
      htmlString = ""
      htmlString << "<div id='#{chart_id}Div' class='fusionchart'>\n\t\t\t\tChart.\n\t\t"
      htmlString << "<fusionchartfree swf='#{chart_swf}' chart_id='#{chart_id}' chart_width='#{chart_width}' chart_height='#{chart_height}' chart_xml='#{chart_xml}' />"
      htmlString << "</div>"
      return htmlString
    end    
  end    
  
  module FCFChartXmlBuilder
    
    # for randomize color
    @FC_ColorCounter=0;
    @arr_FCColors=["1941A5", "AFD8F8", "F6BD0F", "8BBA00", "A66EDD", "F984A1", 
                    "CCCC00", "999999", "0099CC", "FF0000", "006F00", "0099FF", 
                    "FF66CC", "669966", "7C7CB4", "FF9933", "9900FF", "99FFCC", 
                    "CCCCFF", "669900"]
                    
    # Generate xml for chart
    # examples
    #
    # for single charts
    #<graph  yAxisName='Sales Figure' 
    #                caption='Top 5 Sales Person' 
    #                numberPrefix='$' 
    #                decimalPrecision='1' 
    #                divlinedecimalPrecision='0' 
    #                limitsdecimalPrecision='0'>
    #        <set name='Alex' value='25000' color='AFD8F8'/> 
    #        <set name='Mark' value='35000' color='F6BD0F'/> 
    #        <set name='John' value='31300' color='008E8E'/> 
    #
    #</graph>
    #
    # for multi charts
    #<graph  yAxisName='Sales Figure' 
    #                caption='Top 5 Sales Person' 
    #                numberPrefix='$' 
    #                decimalPrecision='1' 
    #                divlinedecimalPrecision='0' 
    #                limitsdecimalPrecision='0'>
    #        <categories>
    #                <category name="Jan"/> 
    #                <category name="Feb"/> 
    #                <category name="Apr"/> 
    #        </categories>
    #        <dataset seriesName="Current Year" color="A66EDD">
    #                <set value="1127654"/> 
    #                <set value="1226234"/> 
    #                <set value="1311565"/> 
    #
    #        </dataset>
    #        <dataset seriesName="Previous Year" color="F6BD0F">
    #                <set value="927654"/> 
    #                <set value="1126234"/> 
    #                <set value="1111565"/> 
    #
    #        </dataset>
    #</graph>    
    
    def self.smchart_xml(category, datasets, options = {})
      if options[:sectionSize].present?
        category[:value_list] = erase_sections(category[:value_list], options[:sectionSize])
        options.delete :sectionSize
      end
      
      xml = ::Builder::XmlMarkup.new(:indent=>0) 
      #pOptions[:caption] = getCaption(valueDatas)
      xml.graph(options) do
        if datasets.length == 1
          category[:value_list].length.times do |index|
            dataset = datasets[0]
            color = category[:color_list].blank? ? "":category[:color_list][index]
            xml.set(:name  => category[:value_list][index], 
                    :value => dataset[:value_list][index],
                    :color => color)
          end
        else
          xml.categories do
            category[:value_list].length.times do |index|
              xml.category(:name  => category[:value_list][index])
            end          
          end
          datasets.each do |dataset|
            dataset[:color] = dataset[:color].blank? ? get_FC_color : dataset[:color] 
            valueList = dataset[:value_list].clone
            dataset.delete :value_list
            xml.dataset(dataset) do
              valueList.each do |value|
                xml.set(:value => value)
              end
            end
          end
        end 
      end
      xmlString = xml.to_s
      return xmlString[0..xmlString.length - 8]            
    end
    


    def self.get_FC_color 
      #Update index
      @FC_ColorCounter=@FC_ColorCounter+1
      counter = @FC_ColorCounter % (@arr_FCColors.size)
      #Return color
      return @arr_FCColors[counter]
    end     
  end

end


