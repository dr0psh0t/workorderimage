class Workorder {
  int joWorkId;
  String scopeOfWork;
  String scopeGroup;
  int isPartsReq;

  Workorder(int joWorkId, String scopeOfWork, String scopeGroup, int isPartsReq) {
    this.joWorkId = joWorkId;
    this.scopeOfWork = scopeOfWork;
    this.scopeGroup = scopeGroup;
    this.isPartsReq = isPartsReq;
  }
}