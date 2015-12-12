unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, OtlParallel, OtlTask, OtlTaskControl, Vcl.StdCtrls;

type
  TFormMain = class(TForm)
    btnExecuteTask: TButton;
    memo: TMemo;
    procedure btnExecuteTaskClick(Sender: TObject);
  private
    fTask: IOmniParallelTask;

    procedure HandleOnTaskStop;
    procedure HandleOnTaskThreadTerminated(const task: IOmniTaskControl);
    procedure TaskToExecute;
    procedure CleanupTask;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.btnExecuteTaskClick(Sender: TObject);
begin
  if Assigned(fTask) then
    Exit;

  memo.Lines.Add('task has been started..');
  fTask := Parallel.ParallelTask.NoWait.NumTasks(1);
  fTask.OnStop(HandleOnTaskStop);
  fTask.TaskConfig(Parallel.TaskConfig.OnTerminated(HandleOnTaskThreadTerminated));
  fTask.Execute(TaskToExecute);
end;

procedure TFormMain.CleanupTask;
begin
  fTask := NIL;
  memo.Lines.Add('task completed.');
end;

procedure TFormMain.HandleOnTaskStop;
begin
  TThread.Queue(nil, CleanupTask);
end;

procedure TFormMain.HandleOnTaskThreadTerminated(const task: IOmniTaskControl);
begin
  if not Assigned(task.FatalException) then
    Exit;

  memo.Lines.Add('an exception occured: ' + task.FatalException.Message);
end;

procedure TFormMain.TaskToExecute;
begin
  Winapi.Windows.Sleep(2000);
  raise Exception.Create('async operation exeption');
end;

end.
