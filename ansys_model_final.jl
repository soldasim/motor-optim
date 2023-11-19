using JLD2
using BOSS
using Distributions

include("./data.jl")
include("./Surrogate_Q_volne_parametry.jl")

"""
Use `f = ansys_model_final()` to retrieve the ansys model.
"""
function ansys_model_final()
    x_dim = 4
    y_dim = 2
    domain = ModelParam.domain()

    return BOSS.Nonparametric(;
        length_scale_priors = fill(Product([truncated(Normal(0., dif/3); lower=0.) for dif in (domain[2][i]-domain[1][i] for i in 1:x_dim)]), y_dim),
    )
end

function save_ansys_params(data)
    save("./motor-optim/ansys_model_params.jld2", data_dict(data))
end

function load_ansys_model()
    data = load_ansys_model_data()
    model = ansys_model_final()
    return BOSS.model_posterior(model, data)
end

function load_ansys_model_data()
    data_dict = load("./motor-optim/ansys_model_params.jld2")
    return BOSS.ExperimentDataMLE(
        convert(Matrix{Float64}, data_dict["X"]),
        convert(Matrix{Float64}, data_dict["Y"]),
        data_dict["θ"],
        data_dict["length_scales"],
        data_dict["noise_vars"],
    )
end