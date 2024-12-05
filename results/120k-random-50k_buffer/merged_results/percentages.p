# output as png image
	set terminal png size 1024,768 crop

	# save file to benchmark.png
	set output "merged_percentages.png"

	# graph a title
	set title "Merged Test Results"

	# nicer aspect ratio for image size
	set size 1,0.7

	# y-axis grid
	set grid y

	# x-axis label
	set xlabel "Percentiles"

	# y-axis label
	set ylabel "Response time \(ms\)"

  set pointsize 1

	set datafile separator ","

  plot "/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-06-00-14-36/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-06-00-14-36","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-06-00-14-59/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-06-00-14-59","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-06-00-15-28/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-06-00-15-28","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-06-00-15-56/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-06-00-15-56","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-06-00-16-30/percentages.csv.fixed" with lines title "localhost:12080 - 2024-12-06-00-16-30",
