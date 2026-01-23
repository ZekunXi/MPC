#include<stdio.h>
#include<stdlib.h>
#include<time.h>

const int N = 3;
const int T = 5;

/*define steady state*/
const int x_ss = -1;
const int y_ss = 0;

/*for example use the average constraint: sigma h(x,y) = x + 2y <= 0*/
int get_stage_constraint(int x, int y);
void arr_printer(int* rec_fisrt_address_of_arr, int length_of_arr);

int main() {
	srand(time(NULL));
	int t_current = 2;
	int i = 0;
	int n = 0;
	int x_past_save[100] = { 6 };
	int y_past_save[100] = { 6 };
	int x0 = -2;
	int y0 = -1;
	int x1 = -4;
	int y1 = 1;
	int x2 = -3;
	int y2 = 0;

	x_past_save[0] = x0;
	y_past_save[0] = y0;
	x_past_save[1] = x1;
	y_past_save[1] = y1;
	x_past_save[2] = x2;
	y_past_save[2] = y2;

	int h_constriant_sum = 0;

	/*here create the online random/prediction arr*/
	int x_online[5] = { 6 };
	int y_online[5] = { 6 };
	int j = 0;
	int x_tmp = 0;
	int y_tmp = 0;
	int h_save[5] = { -100 };


	while (1) {

		/*for index 0,1,2 ====> use the random numbers in the range*/
		for (j = 0; j <= N - 1; j++) {
			x_tmp = rand() % 11 - 5;
			y_tmp = rand() % 11 - 5;
			x_online[j] = x_tmp;
			y_online[j] = y_tmp;
		}
		/*for index 3,4 ====> use the steady state by setting*/
		for (j = N; j <= T - 1; j++) {
			x_online[j] = x_ss;
			y_online[j] = y_ss;
		}

		/*check: that all constraints must be satisfied*/

		int check_flag = 0;
		for (i = 1; i <= T; i++) {
			/*check for every i start!*/
			h_constriant_sum = 0;
			for (n = t_current + i - T; n <= t_current + i - 1; n++) {
				if (n < 0) {
					h_constriant_sum = h_constriant_sum + 0;
				}
				else if ((n >= 0) && (n <= t_current)) {
					h_constriant_sum = h_constriant_sum + get_stage_constraint(x_past_save[n], y_past_save[n]);
				}
				else if (n >= t_current + 1) {
					if ((n >= t_current + 1) && (n <= t_current + N)) {
						h_constriant_sum = h_constriant_sum + get_stage_constraint(x_online[n - t_current - 1], y_online[n - t_current - 1]);
					}
					else if ((n >= t_current + N + 1) && (n <= t_current + T - 1)) {
						h_constriant_sum = h_constriant_sum + get_stage_constraint(x_ss, y_ss);
					}
				}
				else {
					/*NULL*/
				}
			}
			/*check for every i finish!*/
			if (h_constriant_sum <= 0) {
				check_flag++;
			}
			h_save[i - 1] = h_constriant_sum;
			
		}
		if (check_flag == 5) {
			arr_printer(x_online, 5);
			printf("\n");
			arr_printer(y_online, 5);
			printf("\n");
			arr_printer(h_save, 5);
			break;
		}
		
	}

	return 0;
}

int get_stage_constraint(int x, int y) {
	return x + 2 * y;
}

void arr_printer(int* rec_fisrt_address_of_arr, int length_of_arr) {
	int i = 0;
	int* address_of_arr = rec_fisrt_address_of_arr;
	for (i = 0; i < length_of_arr; i++) {
		printf("%d ", address_of_arr[i]);
	}
}