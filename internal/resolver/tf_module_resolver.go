package resolver

type TargetModule struct {
	Env      string
	Provider string
	Stack    string
	Path     string // absolute path to tf dir
}

// type TfModuleResolver struct {
// 	ResolveTargetModule(env, provider, stack string) (*TargetModule, error);
// }
