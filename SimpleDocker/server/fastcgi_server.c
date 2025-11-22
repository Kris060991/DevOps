#include <fcgiapp.h>
#include <stdio.h>

int main() {
  FCGX_Init();
  FCGX_Request req;

  int sockfd = FCGX_OpenSocket("127.0.0.1:8080", 100);
  int flag = 0;

  if (sockfd < 0) {
    printf("ERROR! Socket can`t be opened");
    flag = 1;
    return flag;
  }

  FCGX_InitRequest(&req, sockfd, 0);

  while (FCGX_Accept_r(&req) >= 0) {
  FCGX_FPrintF(req.out, "Content-Type: text/html\n\n");
  FCGX_FPrintF(req.out, "hello world");
  FCGX_Finish_r(&req);
}
  return flag;
}