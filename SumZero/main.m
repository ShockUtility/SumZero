//
//  main.m
//  4개 컬럼의 정수 합이 0인 조합 개수 구하기
//
//  Created by shock on 2016. 8. 12.
//  Copyright © 2016년 shock. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USE_ASYNC   1
//#define DEBUG       1

#define NOW         [[NSDate date] timeIntervalSince1970]
#define IDX_A       0
#define IDX_B       1
#define IDX_C       2
#define IDX_D       3
#define IDX_AB      0
#define IDX_CD      1
#define MAX_VALUE   268435456

NSTimeInterval      startedTime;
int                 outputList[USHRT_MAX];
int                 *sumList[USHRT_MAX][2];

int compare(const void *a, const void *b) {
    return *(int *)a - *(int *)b;
}

void sortAndCount(const int idx, const int sumMax) {
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 합계 배열 정렬
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    mergesort(sumList[idx][IDX_AB], sumMax, sizeof(int), compare);
    mergesort(sumList[idx][IDX_CD], sumMax, sizeof(int), compare);
    
#ifdef DEBUG
    printf("[%d번] 합계 배열 정렬 완료 : %f 초\n", idx+1, NOW-startedTime);
#endif
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 카운팅
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    int zeroCount = 0;
    int idxCD = 0;
    int lastAB = INT_MAX;
    int lastSame = 0;
    
    for (int i=0; i<sumMax; i++) {
        int ab = sumList[idx][IDX_AB][i];
        
        if (ab == lastAB) {
            zeroCount += lastSame;
            continue;
        } else {
            lastAB = ab;
        }
        
        lastSame = 0;
        while (idxCD<sumMax) {
            int cd = sumList[idx][IDX_CD][idxCD];
            
            if (ab < cd) {
                break;
            } else if (ab > cd) {
                idxCD++;
            } else {
                lastSame++;
                idxCD++;
            }
        }
        zeroCount += lastSame;
    }
    
#ifdef DEBUG
    printf("[%d번] 카운팅 완료 : %f 초\n", idx+1, NOW-startedTime);
#endif
    
    outputList[idx] = zeroCount;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        startedTime = NOW;

        int caseCount;
        scanf("%d", &caseCount);
        memset(outputList, -1, USHRT_MAX);

        for (int idx=0; idx<caseCount; idx++) {
            char enter;
            scanf("%c", &enter);
            
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////
            // 입력
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////
            int rowCount;
            scanf("%d", &rowCount);
            if ((rowCount<1) || (rowCount>4000)) {
                printf("%d 번째 케이스의 아이템 갯수 입력이 잘못 되었습니다! (ex : 1~4000)\n", idx+1);
                return 1;
            }

            int inBuffer[4][rowCount];

            for (int i = 0; i < rowCount; i++)
            {
               scanf("%d %d %d %d", inBuffer[IDX_A]+i, inBuffer[IDX_B]+i, inBuffer[IDX_C]+i, inBuffer[IDX_D]+i);
                
                if ((abs(inBuffer[IDX_A][i])>MAX_VALUE)||(abs(inBuffer[IDX_B][i])>MAX_VALUE)||
                    (abs(inBuffer[IDX_C][i])>MAX_VALUE)||(abs(inBuffer[IDX_D][i])>MAX_VALUE)) {
                    printf("%d 번째 케이스의 %d 번째 아이템 입력값이 잘못 되었습니다! (ex : %d~%d)\n",
                           idx+1, i+1, -MAX_VALUE, MAX_VALUE);
                    return 1;
                }
            }
            
#ifdef DEBUG
            printf("[%d번] 입력 완료 : %f 초\n", idx+1, NOW-startedTime);
#endif
            
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////
            // 입력 배열 정렬
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////
            qsort(inBuffer[IDX_A], rowCount, sizeof(int), compare);
            qsort(inBuffer[IDX_B], rowCount, sizeof(int), compare);
            qsort(inBuffer[IDX_C], rowCount, sizeof(int), compare);
            qsort(inBuffer[IDX_D], rowCount, sizeof(int), compare);
            
#ifdef DEBUG
            printf("[%d번] 입력 배열 정렬 완료 : %f 초\n", idx+1, NOW-startedTime);
#endif
            
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////
            // 합계 통합
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////
            int sumMax = rowCount * rowCount;

            sumList[idx][0] = malloc(sizeof(int) * sumMax);
            sumList[idx][1] = malloc(sizeof(int) * sumMax);

            for (int i = 0; i < rowCount; i++)
            {
                for (int j = 0; j < rowCount; j++)
                {
                    int ic = i*rowCount+j;
                    sumList[idx][0][ic] = inBuffer[IDX_A][i] + inBuffer[IDX_B][j];
                    sumList[idx][1][ic] = -(inBuffer[IDX_C][i] + inBuffer[IDX_D][j]);
                }
            }

#ifdef DEBUG
            printf("[%d번] 통합 완료 : %f 초\n", idx+1, NOW-startedTime);
#endif

#ifdef USE_ASYNC
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
#endif
                sortAndCount(idx, sumMax);
#ifdef USE_ASYNC
            });
#endif
        }

        // 각각의 어싱크 루틴이 완료 될때까지 대기한다.
        while (YES) {
            BOOL isAllCompleted = YES;
            for (int i=0; i<caseCount; i++) {
                if (outputList[i]==-1) {
                    isAllCompleted = NO;
                    break;
                }
            }
            if (isAllCompleted) break;
            [NSThread sleepForTimeInterval:0.1f];
        }
        
        // 수집된 결과 출력
        for (int i=0; i<caseCount; i++) {
            printf("\n%d\n", outputList[i]);
        }
        
        printf("\n총 경과시간 : %f 초\n\n", NOW-startedTime);
    }

    return 0;
}




